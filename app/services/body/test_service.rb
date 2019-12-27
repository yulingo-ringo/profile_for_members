module Body
  class TestService
    def initialize(json)
      @json=json
    end
    def execute
      #p @json
      #Faradayを使って、JSON形式のファイルをPOSTできるようにする
      conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
        builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
        builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
        builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
      end

      p @json[:event][:text]
      p "<@#{@json[:event][:user]}>"
      p ENV["SLACK_BOT_USER_TOKEN"]

      #送られて来たメッセージが自分へのメンションなのか他人へのメンションなのか全く関係のないものなのかで場合分け
      if @json[:event][:subtype] != "bot_message"
        if @json[:event][:text] =="<@#{@json[:event][:user]}>"#自分の時
            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "<@#{@json[:event][:user]}>まだURLが用意されていません。"
            }
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
            p body
          
        elsif @json[:event][:text].include?("<@")
              body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],
                :channel => @json[:event][:channel],
                :text  => "その人はまだURLが用意できていません"
              }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        elsif @json[:event][:text].include?("info") || @json[:event][:text].include?("help")
              response = conn.get do |req|  
                req.url '/api/users.list'
                req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
              end
              info = JSON.parse(response&.body)
              members=info["members"]
              body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],
                :channel => @json[:event][:channel],
                :text  => "お困りですか？"
              }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}

              members.each do |member|
                body = {
                  :token => ENV['SLACK_BOT_USER_TOKEN'],
                  :channel => @json[:event][:channel],
                  :text  => "#{member["profile"]["display_name"]}"
                }
                conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
              end

              body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],
                :channel => @json[:event][:channel],
                :text  => "この中のあなたが興味ある人をメンションしてください。名前の前に@をつけるとメンションをすることができます。"
              }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        elsif @json[:event][:text].include?("database")
              body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],
                :channel => @json[:event][:channel],
                :text  => "#{User.find_by(user_id: @json[:event][:user]).user_id}"
              }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        else
            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "こんにちは！mates_profileはワークスペース内の人たちのことをもう少しよく知るためのボットです。ワークスペース内の人をメンションしてください。helpやinfoなどを含むメッセージを送ってもらえればメンバーの名前をリストアップします:blush:"
            }
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        end
      end
    end
  end
end


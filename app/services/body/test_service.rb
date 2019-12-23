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
              :text  => "<@#{@json[:event][:user]}>,your url is not ready"
            }
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
            p body
          
        elsif @json[:event][:text].include?("<@")
              body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],
                :channel => @json[:event][:channel],
                :text  => "Your friend has not finished writing his profile"
              }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        elsif @json[:event][:text].include?("info")
              response = conn.get do |req|  
                req.url '/api/users.list'
                req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
              end
              info = JSON.parse(response&.body)
              members=info[:members]
              members.each do |member|
                p member[:id]
              end
        else
            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "sorry, I don't understand. Please mention someone ¯\_(ツ)_/¯"
            }
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        end
      end
    end
  end
end


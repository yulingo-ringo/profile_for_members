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
        if @json[:event][:text].include?("<@")
          if @json[:event][:text] =="<@#{@json[:event][:user]}>"#自分の時
            text="<@#{@json[:event][:user]}>まだURLが用意されていません。"  
          else 
            text ="その人はまだURLが用意できていません"
          end
            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => text
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
                if member["is_bot"]==false&& member["profile"]["real_name"]!="Slackbot"
                  body = {
                    :token => ENV['SLACK_BOT_USER_TOKEN'],
                    :channel => @json[:event][:channel],
                    :text  => "#{member["profile"]["real_name"]}"
                  }
                  conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
                end
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
        elsif @json[:event][:text]=="button1"
          block_kit_3=[
              {
                  "type": "actions",
                  "elements": [
                    {
                      "type": "button",
                        "text": {
                            "type": "plain_text",
                            "text": "GO",
                            "emoji": false
                        },
                      "url": "https://www.tokyodisneyresort.jp/"
                    }
                  ]
              }
          ]
          
            body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],#あとでherokuで設定します
                :channel => @json[:event][:channel],#こうするとDM内に返信できます
                :text  => "ボタン",
                :blocks => block_kit_3
                }
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}#ヘッダーはつけなければいけないらしい、このままで大丈夫です。
          elsif @json[:event][:text]=="button2"
            block_kit_3=[
                {
                    "type": "actions",
                    "elements": [
                      {
                        "type": "button",
                          "text": {
                              "type": "plain_text",
                              "text": "Fill in the Blank",
                              "emoji": false
                          }
                      }
                    ]
                }
            ]
            
              body = {
                  :token => ENV['SLACK_BOT_USER_TOKEN'],#あとでherokuで設定します
                  :channel => @json[:event][:channel],#こうするとDM内に返信できます
                  :text  => "ボタン",
                  :blocks => block_kit_3
                  }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}#ヘッダーはつけなければいけないらしい、このままで大丈夫です。
  
        else
            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "こんにちは！mates_profileはワークスペース内の人たちのことをもう少しよく知るためのボットです。ワークスペース内の人をメンションしてください。helpやinfoなどを含むメッセージを送ってもらえればメンバーの名前をリストアップします:blush:その他button1とbutton2を使えるようにしました"
              
            }
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        end
      end
    end
  end
end


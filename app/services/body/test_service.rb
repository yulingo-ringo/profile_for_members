module Body
  class TestService
    def initialize(json)
      @json=json
    end
    def execute
      conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
        builder.use Faraday::Request::UrlEncoded  
        builder.use Faraday::Response::Logger     
        builder.use Faraday::Adapter::NetHttp    
      end

      natsuo = Faraday::Connection.new(:url => 'https://mates-profile-app.herokuapp.com') do |builder|
        builder.use Faraday::Request::UrlEncoded  
        builder.use Faraday::Response::Logger     
        builder.use Faraday::Adapter::NetHttp    
      end

      p @json[:event][:text]
      p "<@#{@json[:event][:user]}>"
      p ENV["SLACK_BOT_USER_TOKEN"]
      if @json[:event][:subtype] != "bot_message"
        if @json[:event][:text].include?("<@")
          if @json[:event][:text] =="<@#{@json[:event][:user]}>"
            body=bodies(1)
          else 
            p @json[:event][:text].slice!(2,9)
            body=bodies(2)
          end
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        elsif @json[:event][:text].include?("info") || @json[:event][:text].include?("help")
              #response = conn.get do |req|  
              #  req.url '/api/users.list'
              #  req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
              #end
              # info = JSON.parse(response&.body)
              # members=info["members"]
              body = bodies(3)
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}

              # members.each do |member|
              #   if member["is_bot"]==false&& member["profile"]["real_name"]!="Slackbot"
              #     body = {
              #       :token => ENV['SLACK_BOT_USER_TOKEN'],
              #       :channel => @json[:event][:channel],
              #       :text  => "#{member["profile"]["real_name"]}"
              #     }
              #     conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
              #   end
              # end

              # body = {
              #   :token => ENV['SLACK_BOT_USER_TOKEN'],
              #   :channel => @json[:event][:channel],
              #   :text  => "この中のあなたが興味ある人をメンションしてください。名前の前に@をつけるとメンションをすることができます。"
              # }
              # conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        # elsif @json[:event][:text].include?("database")
        #       body = {
        #         :token => ENV['SLACK_BOT_USER_TOKEN'],
        #         :channel => @json[:event][:channel],
        #         :text  => "#{User.find_by(user_id: @json[:event][:user]).user_id}"
        #       }
        #       conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        elsif @json[:event][:text]=="rtm"
          response = conn.get do |req|  
            req.url '/api/rtm.connect'
            req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
          end
          info = JSON.parse(response&.body)
          p info
          
        elsif @json[:event][:text]=="login"
          response = natsuo.get do |req|  
            req.url '/login'
            req.body = {
              :is_index => true,
              :member_slack_id => @json[:team_id],
              :workspace_id => @json[:team_id],
              :slack_user_id => @json[:event][:user]
            }
          end
          body=bodies(4)
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
          
            body = bodies(3)
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
    def bodies(number)
      case number
      when 1 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "あなたのURLはこちらです！" ,
          :blocks => blocks(1)
        }
      when 2 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "その人はまだURLが用意できていません"
        }
      when 3 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "@名前でメンションしてプロフィールがチェックできます"
        }
      when 4 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "ログインします"
        }
        
        end  
      return body   
    end
    def blocks(number)
      case number
      when 1 then
        block=[
          {
            "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "あなたのURLはこちらです"
              }
          },
          {
            "type": "image",
            "title": {
              "type": "plain_text",
              "text": "Please enjoy this photo of a kitten"
            },
            "block_id": "image4",
            "image_url": "https://icatcare.org/app/uploads/2018/07/Helping-your-new-cat-or-kitten-settle-in-1.png",
            "alt_text": "かわいいでしょ"
          },
          {
              "type": "actions",
              "elements": [
                {
                  "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "Go to your Page",
                        "emoji": false
                    }
                }
              ]
            }
          ]
      when 2 then
        block =[
          {
            "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "Danny Torrence left the following review for your property:"
              }
          }
        ] 
      end
    end
  end
end


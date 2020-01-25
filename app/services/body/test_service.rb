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
      p "この間がjson"
      p @json
      p "この間がjson"
      p "<@#{@json[:event][:user]}>"
      p ENV["SLACK_BOT_USER_TOKEN"]
      if @json[:event][:subtype] != "bot_message"
        if @json[:event][:text].include?("<@")
            response = conn.get do |req|  
                req.url '/api/users.list'
                req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
              end
               info = JSON.parse(response&.body)
               members=info["members"]
               p "この間がメンバー"
               p members
               p "この間メンバー"
               for var in members do
                if @json[:event][:text].include?(var["id"])
                  p "下が名前"
                  p var["profile"]["real_name"]
                  name=var["profile"]["real_name"]
                end
               end
          if @json[:event][:text].include?("<@#{@json[:event][:user]}>")
            body=bodies(1,name)
          else 
            body=bodies(2,name)
          end
            conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
        elsif @json[:event][:text].include?("info") || @json[:event][:text].include?("help")
              #response = conn.get do |req|  
              #  req.url '/api/users.list'
              #  req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
              #end
              # info = JSON.parse(response&.body)
              # members=info["members"]
              body = bodies(3,name)
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
          body=bodies(4,name)
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
          
            body = bodies(3,name)
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
    def bodies(number,name)
      case number
      when 1 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "あなたのURLはこちらです！" ,
          :blocks => blocks(1,name)
        }
      when 2 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "#{@json[:event][:text]}さんのURLはこちらです",
          :blocks => blocks(2,name)
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
    def blocks(number,name)
      case number
      when 1 then
        block=[
          {
            "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "あなたのページに行きましょう！"
              }
          },
          {
            "type": "image",
            "title": {
              "type": "plain_text",
              "text": "プロフィール画像"
            },
            "block_id": "image4",
            "image_url": "https://profile-for-member-delite-quickly.s3-ap-northeast-1.amazonaws.com/myogp.png",
            "alt_text": "下のボタンをクリックしてください"
          },
          {
              "type": "actions",
              "elements": [
                {
                  "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "#{name}さんのページへ！",
                        "emoji": false
                    },
                  "url": "https://mates-profile-app.herokuapp.com/"
                }
              ]
            }
          ]
      when 2 then
        block=[
          {
            "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "#{@json[:event][:text]}さんのプロフィールをみてみよう！"
              }
          },
          {
            "type": "image",
            "title": {
              "type": "plain_text",
              "text": "プロフィール画像"
            },
            "block_id": "image4",
            "image_url": "https://profile-for-member-delite-quickly.s3-ap-northeast-1.amazonaws.com/friendsogp.png",
            "alt_text": "下のボタンをクリックしてください。"
          },
          {
              "type": "actions",
              "elements": [
                {
                  "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "#{name}さんのページへ！",
                        "emoji": false
                    },
                    "url": "https://mates-profile-app.herokuapp.com/",
                    "value": "#{name}"
                }
              ]
            }
          ]
      end
    end
  end
end


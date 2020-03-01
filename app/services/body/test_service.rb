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
      # if @json[:event][:type]=="user_change"
      #   p "hi"
      #   response = conn.get do |req|  
      #     req.url '/api/users.list'
      #     req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
      #   end
      #   info = JSON.parse(response&.body)
      #   members=info["members"]
      #   response = conn.get do |req|  
      #     req.url '/api/team.info'
      #     req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
      #   end
      #   team = JSON.parse(response&.body)
      #   for member in members do
      #     if member["is_bot"]==false&& member["profile"]["real_name"]!="Slackbot"
      #       body ={
      #         :display_name => member["profile"]["real_name"],
      #         :avatar => member["profile"]["image_original"],
      #         :slack_user_id => member["id"],
      #         :workspace_id => team["team"]["id"],
      #         :workspace_avatar=> team["team"]["icon"]["image_34"]
      #       }
      #       p body
      #       natsuo.post '/api/v1/users',body.to_json, {"Content-type" => 'application/json'}
      #     end
      #   end
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
                  image = var["profile"]["image_512"]
                  id=var["id"]
                  member=var
                end
               end
               response_self=natsuo.get do |req|
                req.url "/api/v1/users"
                req.headers["workspace-id"]=@json["team_id"]
              end
              p @json["team_id"]
              p "ユーザーのリストある？？"
              p response_self.body
              p "これの上"
              knowns= JSON.parse(response_self.body)
              p knowns[2]
              p "ハッシュ化されてたら成功"
              for var in knowns do
                if id==var["slack_user_id"]
                  p "ユーザーidが欲しい" 
                  webid=var["_id"]
                  p webid
                  ok=1
                break
                end
                ok=0
              end
              if ok==1
                 response_self=natsuo.put do |req|
                   req.url "/api/v1/users/#{webid}"
                   req.headers["slack_user-id"]=@json["event"]["user"]
                   req.body=var
                 end
                 response = conn.get do |req|  
                  req.url '/api/team.info'
                  req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
                end
                team = JSON.parse(response&.body)
                p "チームの情報下"
                p team
                p "チームの情報上"
                
              else
                response = conn.get do |req|  
                  req.url '/api/team.info'
                  req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
                end
                team = JSON.parse(response&.body)
                p "チームの情報下"
                p team
                p "チームの情報上"
                body ={
                  :display_name => name,
                  :avatar => image,
                  :slack_user_id => id,
                  :workspace_id => @json["team_id"],
                  :workspace_avatar=> team["team"]["icon"]["image_34"]
                  :workspace_name => team["team"]["name"]
                }
                p body
                natsuo.post '/api/v1/users',body.to_json, {"Content-type" => 'application/json'}
              end
              p "ok"
              p ok
              p "ok"

            if @json[:event][:text].include?("<@#{@json[:event][:user]}>")
            p "ワークスペースid"
            p @json["team_id"]
            

            block1 =[
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
                "image_url": image,
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
                      "url": "https://mates-profile-app.herokuapp.com/login?is_index=false&slack_user_id=#{@json["event"]["user"]}&member_slack_id=#{id}&workspace_id=#{@json["team_id"]}",
                      "value": "link"
                    }
                  ]
                }
              ]

            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "#{name}さんのURLはこちらです！",
              :blocks => block1
            }
           
            else 
            block2=[
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
                "image_url": image,
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
                        "url": "https://mates-profile-app.herokuapp.com/login?is_index=false&slack_user_id=#{@json["event"]["user"]}&member_slack_id=#{id}&workspace_id=#{@json["team_id"]}",
                        "value": "link"
                    }
                  ]
                }
              ]

            body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "#{name}さんのURLはこちらです",
              :blocks => block2
            }
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
          elsif @json[:event][:text]=="question"
            block_kit_3=[
                {
                    "type": "actions",
                    "elements": [
                      {
                        "type": "button",
                          "text": {
                              "type": "plain_text",
                              "text": "あなたに質問が届いています",
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
          :text  => "#{name}さんのURLはこちらです！" ,
          :blocks => blocks(1,name)
        }
      when 2 then
        body = {
          :token => ENV['SLACK_BOT_USER_TOKEN'],
          :channel => @json[:event][:channel],
          :text  => "#{name}さんのURLはこちらです",
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


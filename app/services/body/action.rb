module Body
  class Action
      def initialize(json)
          @json=json
      end
      def interact
          conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
              builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
              builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
              builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
          end
          natsuo = Faraday::Connection.new(:url => 'https://mates-profile-app.herokuapp.com') do |builder|
            builder.use Faraday::Request::UrlEncoded  
            builder.use Faraday::Response::Logger     
            builder.use Faraday::Adapter::NetHttp    
          end

          {"type"=>"block_actions",
           "team"=>{
             "id"=>"TPUL203HT", 
             "domain"=>"mates-ex"
             }, 
          "user"=>{
            "id"=>"UPH64QN9Z", 
            "username"=>"yulikamiya", 
            "name"=>"yulikamiya", 
            "team_id"=>"TPUL203HT"
            }, 
          "api_app_id"=>"ARNCWPSH1", 
          "token"=>"qIWZtvkTjKjwnbh390UYzBdQ", 
          "container"=>{
            "type"=>"message", 
            "message_ts"=>"1579955699.005200", 
            "channel_id"=>"DRZNAR1RA", 
            "is_ephemeral"=>false
            }, 
          "trigger_id"=>"923831594615.810682003605.8d972393040b6ddeb049715acca6ffb6", 
          "channel"=>{
            "id"=>"DRZNAR1RA", 
            "name"=>"directmessage"
           }, 
          "message"=>{
            "type"=>"message", 
            "subtype"=>"bot_message", 
            "text"=>"あなたのURLはこちらです！", 
            "ts"=>"1579955699.005200", 
            "username"=>"profile_for_members", 
            "bot_id"=>"BRZNAQHPW", 
            "blocks"=>
            [
              {
                "type"=>"section", 
                "block_id"=>"wkcW", 
                "text"=>{
                  "type"=>"mrkdwn", 
                  "text"=>"あなたのページに行きましょう！", 
                  "verbatim"=>false
                  }
              }, 
              {
                "type"=>"image", 
                "block_id"=>"image4", "image_url"=>"https://profile-for-member-delite-quickly.s3-ap-northeast-1.amazonaws.com/myogp.png", "alt_text"=>"下のボタンをクリックしてください", "title"=>{"type"=>"plain_text", "text"=>"プロフィール画像", "emoji"=>true}, "fallback"=>"842x595px+image", "image_width"=>842, "image_height"=>595, "image_bytes"=>23453}, {"type"=>"actions", "block_id"=>"1HCQe", "elements"=>[{"type"=>"button", "action_id"=>"CK+", "text"=>{"type"=>"plain_text", "text"=>"ゆりさんのページへ！", "emoji"=>false}, "url"=>"https://mates-profile-app.herokuapp.com/"}]}]}, "response_url"=>"https://hooks.slack.com/actions/TPUL203HT/909180714466/TwWmmjJdjFO5i1mVAJUz4nLU", "actions"=>[{"action_id"=>"CK+", "block_id"=>"1HCQe", "text"=>{"type"=>"plain_text", "text"=>"ゆりさんのページへ！", "emoji"=>false}, "type"=>"button", "action_ts"=>"1579955742.969852"}]}

          p @json
          response = conn.get do |req|  
            req.url '/api/users.list'
            req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
          end
           info = JSON.parse(response&.body)
           members=info["members"]
           p "この間がメンバー"
     #      p members
           p "この間メンバー"
           for var in members do
            p "テキストとその下は名前！"
            p @json["message"]["text"]
            p var["profile"]["real_name"]
            if @json["message"]["text"].include?(var["profile"]["real_name"])
              p "下がアクションの名前"
              p var["id"]
            end
           end
            p @json["user"]
            response = natsuo.get do |req|  
                req.url '/login'
             #   req.headers['Content-Type'] = 'application/html'
                req.body = {
                  :is_index => true,
                  :member_slack_id => var["id"],
                  :workspace_id => @json["team"]["id"],
                  :slack_user_id => @json["user"]["id"]
                }
                p req.body
              end
            
            # view = {
            #     "type": "modal",
            #     "title": {
            #         "type": "plain_text",
            #         "text": "質問箱"
            #     },
            #     "blocks": [
            #         {
            #         "type": "section",
            #         "text": {
            #             "type": "mrkdwn",
            #             "text": "あなたが好きな映画は？"
            #         },
            #         "block_id": "section1",
            #         # "accessory": {
            #         #     "type": "button",
            #         #     "text": {
            #         #     "type": "plain_text",
            #         #     "text": "Click me"
            #         #     },
            #         #     "action_id": "button_abc",
            #         #     "value": "Button value",
            #         #     "style": "danger"
            #         # }
            #          },
            #         {
            #         "type": "input",
            #         "label": {
            #             "type": "plain_text",
            #             "text": "Input label"
            #         },
            #         "element": {
            #             "type": "plain_text_input",
            #             "action_id": "input1",
            #             "placeholder": {
            #             "type": "plain_text",
            #             "text": "Type in here"
            #             },
            #             "multiline": false
            #         },
            #         "optional": false
            #         }
            #     ],
            #     "close": {
            #         "type": "plain_text",
            #         "text": "Cancel"
            #     },
            #     "submit": {
            #         "type": "plain_text",
            #         "text": "Save"
            #     },
            #     "private_metadata": "Shhhhhhhh",
            #     "callback_id": "view_identifier_12"
            #     }

            #     body = {
            #     :token => ENV['SLACK_BOT_USER_TOKEN'],#あとでherokuで設定します
            #     :trigger_id => @json["trigger_id"],#こうするとDM内に返信できます
            #     :view => view
            #     }
            # conn.post '/api/views.open',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}#ヘッダーはつけなければいけないらしい、このままで大丈夫です。
   #       end    
      end
  end   
end
module Body
  class Lambda
    def initialize
    end
    def question
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
   
      

      question = natsuo.get do |req|
        req.url '/api/v1/questions/default'
        req.headers[:is_from_slack]= "true"
      end
      

       p "質問ありますか"
       p question
       p "質問ありますか"
       hashed_question = JSON.parse(question&.body)
       p hashed_question["content"]
       content = hashed_question["content"]
       #id = hashed_question["_id"]
       p content
       body={
         :content => content
       }
      response=natsuo.post '/api/v1/questions',body.to_json, {"Content-Type"=> "application/json","workspace-id" => 'TPUL203HT',"slack-user-id"=>"UPH64QN9Z"}
      p "レスポンスある？前"
      p response.body
      getid=JSON.parse(response.body)
      p getid["_id"]
      id=getid["_id"]
      p "レスポンスある？後"
      hash = JSON.parse(response.body)
      block=[
        {
          "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "こんにちは、mates profileです<br>あなたに質問が届いています。"
            }
        },
        {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                  "text": {
                      "type": "plain_text",
                      "text": "いますぐ答えよう！",
                      "emoji": false
                  },
                "value": "#{content} #{id}"
              }
            ]
        }
      ]
      # body = {
      #   :token => ENV['SLACK_BOT_USER_TOKEN'],
      #   :channel => "#general",
      #   :text  => "あなたに質問が届いています",
      #   :blocks => block
      # }
      # conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}

      response = conn.get do |req|  
        req.url '/api/conversations.list'
        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
        req.params[:types] = "im"
      end
      hash = JSON.parse(response.body)
      p "コンバセーションリストは下"
      p hash
      # hash["channels"]
       for var in hash["channels"] do
        p "それぞれのユーザーでうまく行っているか1"
        p var["user"]

        response_self=natsuo.get do |req|
          req.url "/api/v1/users"
          req.headers["workspace-id"]= "TPUL203HT"
        end
        knowns= JSON.parse(response_self.body)
        p "ナツオのget Users の返信"
        p knowns
        p "上がget Usersの返信"
        for var2 in knowns do
          p "それぞれのユーザーでうまく行っているか2"
          p var2["slack_user_id"]
          if var["user"]==var2["slack_user_id"]
            p "それぞれのユーザーでうまく行っているか3"
            p var2["slack_user_id"]
            body={
              :content => content
            }
           response=natsuo.post '/api/v1/questions',body.to_json, {"Content-Type"=> "application/json","workspace-id" => 'TPUL203HT',"slack-user-id"=>var["user"]}
           p "レスポンスある？前"
           p response.body
           getid=JSON.parse(response.body)
           p getid["_id"]
           id=getid["_id"]
             p var["id"]
             block=[
              {
                  "type": "actions",
                  "elements": [
                    {
                      "type": "button",
                        "text": {
                            "type": "plain_text",
                            "text": "今すぐ答えよう！",
                            "emoji": false
                        },
                      "value": "#{content} #{id}"
                    }
                  ]
              }
            ]
              body = {
                :token => ENV['SLACK_BOT_USER_TOKEN'],
                :channel => "#{var["id"]}", #全員に対して個人DMしたくなったらこれを起動しましょう
          #      :channel => "#general",
                :text  => "あなたに質問があります",
                :blocks => block
              }
              conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
           
            end
    
            
          break
          end
        end

        
    end
  end
end
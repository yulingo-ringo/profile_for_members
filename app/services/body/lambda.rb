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
       hashed_question = JSON.parse(question&.body)
       content = hashed_question["content"]
       body={
         :content => content
       }
      response=natsuo.post '/api/v1/questions',body.to_json, {"Content-Type"=> "application/json","workspace-id" => 'TPUL203HT',"slack-user-id"=>"UPH64QN9Z"}
      getid=JSON.parse(response.body)
      id=getid["_id"]
      hash = JSON.parse(response.body)
      response = conn.get do |req|  
        req.url '/api/conversations.list'
        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
        req.params[:types] = "im"
      end
      hash = JSON.parse(response.body)
      response_self=natsuo.get do |req|
        req.url "/api/v1/users"
        req.headers["workspace-id"]= "TPUL203HT"
      end
      knowns= JSON.parse(response_self.body)
      for member in knowns do
        p "ナツオの方に誰がいるのかチェック"
        p member["slack_user_id"]
        p member["display_name"]
      end
       for var in hash["channels"] do
        p "slackにはいる人たち"
        p var["user"]  
        for var2 in knowns do
          p "それぞれのユーザーでうまく行っているか2"
          p var2["slack_user_id"]
          p var2["display_name"]
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
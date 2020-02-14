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
   
      response = conn.get do |req|  
        req.url '/api/conversations.list'
        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
        req.params[:types] = "im"
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

       body={
         :content => hashed_question[:content]
       }

      natsuo.post '/api/v1/questions/default',body.to_json, {"workspace_id" => 'TPUL203HT',"slack_user_id"=>"UPH64QN9Z"}

      hash = JSON.parse(response.body)
      body = {
        :token => ENV['SLACK_BOT_USER_TOKEN'],
   #     :channel => "#{var["id"]}", 全員に対して個人DMしたくなったらこれを起動しましょう
        :channel => "#general",
        :text  => "あなたに質問があります"
       
      }
      conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
    
       hash["channels"]
       for var in hash["channels"] do
         p var["id"]
      #    body = {
      #      :token => ENV['SLACK_BOT_USER_TOKEN'],
      # #     :channel => "#{var["id"]}", 全員に対して個人DMしたくなったらこれを起動しましょう
      #      :channel => "#general",
      #      :text  => "あなたに質問があります"
          
      #    }
      #    conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
       
        end

    end
  end
end
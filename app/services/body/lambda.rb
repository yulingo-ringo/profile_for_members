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
      
      web = Faraday::Connection.new(:url => 'https://mates-profile-app.herokuapp.com') do |builder|
        builder.use Faraday::Request::UrlEncoded  
        builder.use Faraday::Response::Logger     
        builder.use Faraday::Adapter::NetHttp    
      end
   
      response = conn.get do |req|  
        req.url '/api/conversations.list'
        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
        req.params[:types] = "im"
      end

      # question = web.get do |req|
      #   req.url '/api/v1/questions/default'
      #   req.headers[:is_from_slack]=true
      # end
      # hashed_question = JSON.parse(question)

      # body={
      #   :content => hashed_question[:content]
      # }

      # conn.post '/api/chat.postMessage',body.to_json, {"workspace_id" => '???',"slack_user_id"=>"???"}

      hash = JSON.parse(response.body)
      #p hash["channels"]
      # for var in hash["channels"] do
      #   p var["id"]
      #   body = {
      #     :token => ENV['SLACK_BOT_USER_TOKEN'],
      #     :channel => "#{var["id"]}",
      #     :text  => "あなたに質問があります"
          
      #   }
      #   conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}
      # end
      p "ハッシュ化されてる？"

    end
  end
end
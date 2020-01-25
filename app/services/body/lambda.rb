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
      
      body = {
        :token => ENV['SLACK_BOT_USER_TOKEN'],
        :channel => "#general",
        :text  => "あなたに質問があります"
        
      }
      conn.post '/api/chat.postMessage',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}

      response = conn.get do |req|  
        req.url '/api/conversations.list'
        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
        req.params[:types] = "im"
      end
      hash = JSON.parse(response.body)
      p hash["channels"]
      for var in hash["channels"] do
        p hash["channels"][var]["id"]
      end
      p "ハッシュかされてる？"

    end
  end
end
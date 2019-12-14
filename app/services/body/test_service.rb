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
      token=ENV['SLACK_BOT_USER_TOKEN']

      #送られて来たメッセージが自分へのメンションなのか他人へのメンションなのか全く関係のないものなのかで場合分け
      if @json[:event][:text] =="<@#{@json[:event][:user]}>"#自分の時
        json_str='{
          "ok": true,
          "channel": "CP9RQQL7P",
          "ts": "1576302514.000100",
          "message": {
            "type": "message",
            "subtype": "bot_message",
            "text": "\u4eca\u304b\u3089\u5e30\u308b\u3088",
            "ts": "1576302514.000100",
            "username": "mates_profile_practice_4",
            "bot_id": "BRDU34RLM"
          }
          }'
          body= JSON.parse(json_str)
        conn.post '/api/chat.postMessage', body, {"Content-type" => "application/json","Authorization"=>"Bearer #{token}"}
          #conn.post do |req|
          #req.url '/api/chat.postMessage'
          
          #req.body= JSON.parse(json_str)
          #req.body = {
          #  :token => ENV['BOT_OAUTH_TOKEN'],
          #  :channel => @json[:event][:channel],
          #  :text  => "<@#{@json[:event][:user]}>,your url is not ready"
          #}
          p body
        #end
        
      elsif @json[:event][:text].include?("<@")
        conn.post do |req|
          req.url '/api/chat.postMessage'
            req.body = {
              :token => ENV['BOT_OAUTH_TOKEN'],
              :channel => @json[:event][:channel],
              :text  => "Your friend has not finished writing his profile"
            }
          end
        
      else
        conn.post do |req|
          req.url '/api/chat.postMessage'
          req.body = {
            :token => ENV['BOT_OAUTH_TOKEN'],
            :channel => @json[:event][:channel],
            :text  => "sorry, I don't understand. Please mention someone ¯\_(ツ)_/¯"
          }
        end
      end
    end
  end
end


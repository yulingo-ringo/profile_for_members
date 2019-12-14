module Body
  class TestService
    def initialize(json)
      @json=json
    end
    def execute
      p @json
      #Faradayを使って、JSON形式のファイルをPOSTできるようにする
      conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
        builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
        builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
        builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
      end

      #送られて来たメッセージが自分へのメンションなのか他人へのメンションなのか全く関係のないものなのかで場合分け
      if @json[:event][:text] =="<@#{@json[:event][:user]}>"#自分の時
        conn.post do |req|
          req.url '/api/chat.postMessage'
          req.body = {
            :token => ENV['BOT_OAUTH_TOKEN'],
            :channel => @json[:event][:channel],
            :text  => "<@#{@json[:event][:user]}>,your url is not ready"
          }
        end
        
      elsif @json[:event][:text].include?("<@")
        req.url '/api/chat.postMessage'
          req.body = {
            :token => ENV['BOT_OAUTH_TOKEN'],
            :channel => @json[:event][:channel],
            :text  => "Your friend has not finished writing his profile"
          }
        
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


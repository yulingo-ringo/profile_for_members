module Body
  class TestService
    #JSON形式のファイルがハッシュになったものを受け取る
    attr_accessor :json

    #Faradayを使って、JSON形式のファイルをPOSTできるようにする
    conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
      builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
      builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
      builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
    end

    #送られて来たメッセージが自分へのメンションなのか他人へのメンションなのか全く関係のないものなのかで場合分け
    if self.json["event"]["text"] =="<@#{self.json["event"]["user"]}>"#自分の時
      conn.post do |req|
        req.url '/api/chat.postMessage'
        req.body = {
          :token => :ENV['BOT_OAUTH_TOKEN'],
          :channel => :self.json["event"]["channel"],
          :text  => "<@#{self.json["event"]["user"]}>,your url is not ready"
        }
      end
      
    elsif self.json["event"]["text"].include?("<@")
      req.url '/api/chat.postMessage'
        req.body = {
          :token => :ENV['BOT_OAUTH_TOKEN'],
          :channel => :self.json["event"]["channel"],
          :text  => "Your friend has not finished writing his profile"
        }
      
    else
      conn.post do |req|
        req.url '/api/chat.postMessage'
        req.body = {
          :token => :ENV['BOT_OAUTH_TOKEN'],
          :channel => :self.json["event"]["channel"],
          :text  => "sorry, I don't understand. Please mention someone ¯\_(ツ)_/¯"
        }
    end


    
    # def web_client
    #   @web_client ||= Slack::Web::Client.new
    # end
      
    # def real_time_client
    #   @real_time_client ||= Slack::RealTime::Client.new
    # end

    
    
    # client=Slack::RealTime::Client.new
  
    # client.on :hello do
    #     puts(
    #       "Successfully connected, welcome '#{client.self.name}' to " \
    #       "the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
    #     )
    # end
      
    # client.on :message do |data|
    #   puts data
    
    #   client.typing channel: data.channel
    
    #   case data.text
    #   when "@#{user_id}"
    #     client.message channel: data.channel, text: "@#{user_id}is not ready"
    #   when /^bot/
    #     client.message channel: data.channel, text: "Sorry,I'm not prepared for that response"
    #   end
    # end
      
    # client.on :close do |_data|
    #   puts 'Connection closing, exiting.'
    # end
      
    # client.on :closed do |_data|
    #   puts 'Connection has been disconnected.'
    # end
      
  end
end


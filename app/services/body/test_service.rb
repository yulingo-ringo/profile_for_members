module Body
  class TestService
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


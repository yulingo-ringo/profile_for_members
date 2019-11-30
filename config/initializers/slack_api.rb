require 'slack'

Slack.configure do |config|
  config.token = ENV['BOT_TOKEN']="xoxp-779091419522-791405671428-856691438550-e20449b7b0029e2013689c14fd63738c"
end

Slack::Web::Client.config do |config|
  config.user_agent = 'Slack Ruby Client/1.0'
end

Slack::RealTime::Client.config do |config|
  config.start_method = :rtm_start
end
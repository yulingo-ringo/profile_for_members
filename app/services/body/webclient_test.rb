client = Slack::Web::Client.new
client.auth_test

client.chat_postMessage(channel: '#general', text: 'Hello World', as_user: true)
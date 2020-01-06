module Body
  class Action
      def initialize(json)
          @json=json
      end
      def interact
          conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
              builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
              builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
              builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
          end
          view = {
              "type": "modal",
              "title": {
                  "type": "plain_text",
                  "text": "Modal title"
              },
              "blocks": [
                  {
                  "type": "section",
                  "text": {
                      "type": "mrkdwn",
                      "text": "あなたが好きな映画は？"
                  },
                  "block_id": "section1",
                  "accessory": {
                      "type": "button",
                      "text": {
                      "type": "plain_text",
                      "text": "Click me"
                      },
                      "action_id": "button_abc",
                      "value": "Button value",
                      "style": "danger"
                  }
                  },
                  {
                  "type": "input",
                  "label": {
                      "type": "plain_text",
                      "text": "Input label"
                  },
                  "element": {
                      "type": "plain_text_input",
                      "action_id": "input1",
                      "placeholder": {
                      "type": "plain_text",
                      "text": "Type in here"
                      },
                      "multiline": false
                  },
                  "optional": false
                  }
              ],
              "close": {
                  "type": "plain_text",
                  "text": "Cancel"
              },
              "submit": {
                  "type": "plain_text",
                  "text": "Save"
              },
              "private_metadata": "Shhhhhhhh",
              "callback_id": "view_identifier_12"
              }

              body = {
              :token => ENV['SLACK_BOT_USER_TOKEN'],#あとでherokuで設定します
              :trigger_id => @json["trigger_id"],#こうするとDM内に返信できます
              :view => view
              }
          conn.post '/api/views.open',body.to_json, {"Content-type" => 'application/json',"Authorization"=>"Bearer #{ENV['SLACK_BOT_USER_TOKEN']}"}#ヘッダーはつけなければいけないらしい、このままで大丈夫です。
            
      end
  end   
end
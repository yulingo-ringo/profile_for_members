class SlackController < ApplicationController
    def index
        Body::TestService.new
    end

    def create
        @body = JSON.parse(request.body.read)
        case @body['type']
        when 'url_verification'
            render json: @body
        when 'event_callback'
            # ..
        end
        @json_hash  = params[:slack]
        client = Body::TestService.new
        client.json = @json_hash
        
    end

    def new
        hash = JSON.parse(json_str)
        members=hash["members"]
        members.each do |member|
            @user=User.new(user_id:member["id"],name:member["name"])
            @user.save
        end
    end

end

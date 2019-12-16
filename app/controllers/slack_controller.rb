class SlackController < ApplicationController
    def index
        Body::TestService.new
    end

    def creat
        #p params
        @body = JSON.parse(request.body.read)
        case @body['type']
        when 'url_verification'
            render json: @body
        when 'event_callback'
            # ..
        end
        json_hash  = params[:slack]
        Body::TestService.new(json_hash).execute      
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

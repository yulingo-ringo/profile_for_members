class SlackController < ApplicationController
    def index
        Body::TestService.new
    end

    def create
        #p params
        @body = JSON.parse(request.body.read)
        p @body["type"]
        case @body["type"]
        when 'url_verification'
            render json: @body
        when 'event_callback'
            # ..
        end
        json_hash  = params[:slack]
        Body::TestService.new(json_hash).execute      
    end

    def action
        body_before=URI.decode(request.body.read)
        gonna_parse=body_before.gsub(/payload=/,"")
        body = JSON.parse(gonna_parse)
        Body::Action.new(body).interact
    end

    def new
        hash = JSON.parse(json_str)
        members=hash["members"]
        members.each do |member|
            @user=User.new(user_id:member["id"],name:member["name"])
            @user.save
        end
    end

    def lambda
        Body::Lambda.question
    end

end

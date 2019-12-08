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
        Body::TestService.new
    end

end

class SlackController < ApplicationController
    def index
        Body::TestService.new
    end

    def create
        render json: {
            challenge:params[:challenge]
        }
    end

end

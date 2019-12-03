class SlackController < ApplicationController
    def index
        Body::TestService.new
    end

    def create
        render json: params[:challenge]
    end

end

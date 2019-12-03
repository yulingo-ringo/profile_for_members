class SlackController < ApplicationController
    def index
        Body::TestService.new
    end
end

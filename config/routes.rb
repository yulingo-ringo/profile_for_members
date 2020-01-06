Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/"=>"slack#index"
  post "/hello"=>"slack#create"
  post "/action"=>"slack#action"
end


class DeliveryController < ApplicationController

  get '/deliveries' do
    erb :'deliveries/index'
  end

end

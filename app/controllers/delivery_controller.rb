class DeliveryController < ApplicationController

  get '/deliveries' do
    @new_requests = Delivery.new_requests
    @confirmed_requests = Delivery.confirmed_requests
    @completed_requests = Delivery.completed_requests
    erb :'deliveries/index'
  end

end

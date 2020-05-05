class DeliveryController < ApplicationController

  get '/deliveries' do
    if is_logged_in?(session)
      @new_requests = Delivery.new_requests
      @confirmed_requests = Delivery.confirmed_requests
      @completed_requests = Delivery.completed_requests
      erb :'deliveries/index'
    else
      redirect "/"
    end
  end

  get '/deliveries/new' do
    if session[:user_type] == "member"
      erb :'deliveries/new'
    else
      session[:message] = "You must be logged in as a community member to create a new delivery request."
      redirect "/deliveries"
    end
  end

  # --- HELPER METHODS --- #

  helpers do

    def is_logged_in?(session)
      !!session[:user_id]
    end

  end

end

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
    if is_member?(session)
      erb :'deliveries/new'
    else
      session[:message] = "You must be logged in as a community member to create a new delivery request."
      redirect "/deliveries"
    end
  end

  post '/deliveries' do
    # TODO: guard against blank delivery requests
    if is_member?(session)
      @delivery = Delivery.new(params)
      @delivery.member = Member.find(session[:user_id])
      @delivery.status = "new"
      @delivery.save

      redirect "/deliveries"
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

    def is_member?(session)
      session[:user_type] == "member" && is_logged_in?(session)
    end

  end

end

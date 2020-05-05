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

  get '/deliveries/:id' do
    # TODO: update to guard against out-of-bounds delivery IDs
    # same for members/volunteers
    if is_logged_in?(session)
      @delivery = Delivery.find(params[:id])

      if @delivery
        erb :'deliveries/show'
      else
        session[:message] = "Can't find a delivery with that ID. Choose from one of these deliveries."
        redirect "/deliveries"
      end
    else
      session[:message] = "You must be logged in to view delivery details."
      redirect "/"
    end
  end

  get '/deliveries/:id/edit' do
    if is_logged_in?(session)
      @delivery = Delivery.find(params[:id])

      if @delivery.member_id == session[:user_id] && is_member?(session) || @delivery.volunteer_id == session[:user_id] && is_volunteer?(session)
        erb :'deliveries/edit'
      else
        session[:message] = "You can only edit a delivery where you are either the member or volunteer."
        redirect "/deliveries/#{params[:id]}"
      end
    else
      session[:message] = "You must be logged in to edit delivery details."
      redirect "/"
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

    def is_volunteer?(session)
      session[:user_type] == "volunteer" && is_logged_in?(session)
    end

  end

end

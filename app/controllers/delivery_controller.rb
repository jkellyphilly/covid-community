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

  get '/deliveries/:id/volunteer' do
    if is_volunteer?(session)
      @delivery = Delivery.find(params[:id])

      if (@delivery.status == "new" && !@delivery.volunteer) || (@delivery.volunteer_id == session[:user_id])
        erb :'deliveries/volunteer'
      else
        session[:message] = "You can only edit a delivery where you are either the member or volunteer."
        redirect "/deliveries/#{params[:id]}"
      end
    else
      session[:message] = "You must be logged in with a volunteer account to sign up for making this delivery."
      redirect "/deliveries/#{params[:id]}"
    end
  end

  get '/deliveries/:id/edit' do
    # TODO: if a delivery has been completed, can't be edited

    @delivery = Delivery.find(params[:id])

    if is_member?(session) && @delivery.member_id == session[:user_id]
      if @delivery.status == "new"
        erb :'deliveries/edit'
      else
        session[:message] = "We're sorry, but this delivery has already been confirmed by a volunteer and cannot be edited. Please contact the volunteer listed below if you need to make changes."
        redirect "/deliveries/#{@delivery.id}"
      end
    else
      session[:message] = "You must be logged in with a member account that owns this delivery request to edit details of the delivery."
      redirect "/deliveries/#{@delivery.id}"
    end
  end

  patch '/deliveries/:id' do
    @delivery = Delivery.find(params[:id])
    if is_volunteer?(session)
      @volunteer = Volunteer.find(session[:user_id])
      case params[:status]
      when "confirmed"
        @delivery.status = "confirmed"
        @volunteer.deliveries << @delivery
        @volunteer.save
      when "completed"
        @delivery.update(status: "completed")
      when "new"
        @delivery.update(status: "new", volunteer_id: nil)
      else
        session[:message] = "Internal error occurred - the status message was outside of the expected range for deliveries."
      end
    elsif is_member?(session)
      @member = Member.find(session[:user_id])
      @delivery.update(items: params[:items], date: params[:date])
    else
      session[:message] = "Internal error occurred."
    end

    redirect "/deliveries"
  end

  delete '/deliveries/:id' do
    @delivery = Delivery.find(params[:id])
    @delivery.destroy if (is_member?(session) && @delivery.member_id == session[:user_id])

    redirect "/deliveries"
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

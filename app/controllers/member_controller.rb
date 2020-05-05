class MemberController < ApplicationController

  get '/members' do
    if is_logged_in?(session)
      @all_members = Member.all
      erb :'members/index'
    else
      # TODO: add flash message that you're not logged in
      # customize to members
      redirect "/members/login"
    end
  end

  get '/members/signup' do
    if !is_logged_in?(session)
      erb :'members/signup'
    else
      # TODO: add flash message that you're already logged in
      redirect "/deliveries"
    end
  end

  post '/members/signup' do
    if username_already_taken?(params[:member][:username])
      # TODO: add flash message that this username is already taken
      session[:message] = "The username you entered is already being used by another member in our database. Please enter a new username."
      redirect "/members/signup"
    else
      @member = Member.new(params[:member])

      if @member.save
        session[:user_type] = "member"
        session[:user_id] = @member.id
        redirect "/deliveries"
      else
        # TODO: add in flash message that all fields must be filled out correctly
        session[:message] = "Error: all non-optional fields must be filled out in order to sign up. Please try again."
        redirect "/members/signup"
      end
    end
  end

  get '/members/login' do
    erb :'members/login'
  end

  get '/members/:username' do
    if is_logged_in?(session)
      @member = Member.find_by(username: params[:username])
      erb :'members/show'
    else
      session[:message] = "You must be logged in to view a member's profile. Please log in to continue."
      redirect "/members/login"
    end
  end

  # --- HELPER METHODS --- #

  helpers do

    def is_logged_in?(session)
      !!session[:user_id]
    end

    def username_already_taken?(username)
      !!Member.find_by(username: username)
    end

  end

end

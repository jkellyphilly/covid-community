class VolunteerController < ApplicationController

  get '/volunteers' do
    if is_logged_in?(session)
      @all_volunteers = Volunteer.all
      erb :'volunteers/index'
    else
      # TODO: add flash message that you're not logged in
      # customize to members
      redirect "/volunteers/login"
    end
  end

  get '/volunteers/signup' do
    if !is_logged_in?(session)
      erb :'volunteers/signup'
    else
      # TODO: add flash message that you're already logged in
      redirect "/deliveries"
    end
  end

  post '/volunteers/signup' do
    if username_already_taken?(params[:volunteer][:username])
      # TODO: add flash message that this username is already taken
      session[:message] = "The username you entered is already being used by another volunteer in our database. Please enter a new username."
      redirect "/volunteers/signup"
    else
      @volunteer = Volunteer.new(params[:volunteer])

      if @volunteer.save
        session[:user_type] = "volunteer"
        session[:user_id] = @volunteer.id
        redirect "/deliveries"
      else
        # TODO: add in flash message that all fields must be filled out correctly
        session[:message] = "Error: all fields must be filled out in order to sign up. Please try again."
        redirect "/volunteers/signup"
      end
    end
  end

  get '/volunteers/login' do
    if !is_logged_in?(session)
      erb :'volunteers/login'
    else
      # TODO: add message "you're already logged in!"
      session[:message] = "You're already logged in - welcome again to the site!"
      redirect "/deliveries"
    end
  end

  post '/volunteers/login' do
    @volunteer = Volunteer.find_by(username: params[:username])

    if @volunteer && @volunteer.authenticate(params[:password])
      session[:user_id] = @volunteer.id
      session[:user_type] = "volunteer"
      redirect "/deliveries"
    else
      session[:message] = "Incorrect username or password. Please try again."
      redirect "volunteers/login"
    end
  end

  # View a volunteer's profile page
  get '/volunteers/:username' do
    if is_logged_in?(session)
      @volunteer = Volunteer.find_by(username: params[:username])
      erb :'volunteers/show'
    else
      session[:message] = "You must be logged in to view a volunteer's profile. Please log in to continue."
      redirect "/volunteers/login"
    end
  end

  # Page for editing a volunteer's information
  get '/volunteers/:username/edit' do
    if is_logged_in?(session)
      @volunteer = Volunteer.find_by(username: params[:username])
      erb :'volunteers/edit'
    else
      session[:message] = "You must be logged in to view a volunteer's profile. Please log in to continue."
      redirect "/volunteers/login"
    end
  end

  #patch '/volunteers/:username'

  # --- HELPER METHODS --- #

  helpers do

    def is_logged_in?(session)
      !!session[:user_id]
    end

    def username_already_taken?(username)
      !!Volunteer.find_by(username: username)
    end

    def is_volunteer?(session)
      session[:user_type] == "volunteer" && is_logged_in?(session)
    end

  end

end

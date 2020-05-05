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

  # --- HELPER METHODS --- #

  helpers do

    def is_logged_in?(session)
      !!session[:user_id]
    end

    def username_already_taken?(username)
      !!Volunteer.find_by(username: username)
    end

  end

end

class VolunteerController < ApplicationController

  get '/volunteers' do
    if is_logged_in?(session)
      @all_volunteers = Volunteer.all
      erb :'volunteers/index'
    else
      session[:message] = "You're not logged in - log in here as a volunteer to see the community."
      redirect "/volunteers/login"
    end
  end

  get '/volunteers/signup' do
    if !is_logged_in?(session)
      erb :'volunteers/signup'
    else
      session[:message] = "You're already logged in as a #{session[:user_type]}. If you'd like to sign up with a new account, please log out first."
      redirect "/deliveries"
    end
  end

  post '/volunteers/signup' do
    if username_already_taken?(params[:volunteer][:username])
      session[:message] = "The username you entered is already being used by another volunteer in our database. Please use a different username."
      redirect "/volunteers/signup"
    else
      @volunteer = Volunteer.new(params[:volunteer])

      if @volunteer.save
        session[:user_type] = "volunteer"
        session[:user_id] = @volunteer.id
        redirect "/deliveries"
      else
        session[:message] = "Error: all fields must be filled out in order to sign up. Please try again."
        redirect "/volunteers/signup"
      end
    end
  end

  get '/volunteers/login' do
    if !is_logged_in?(session)
      erb :'volunteers/login'
    else
      session[:message] = "You're already logged in - if you'd like to log in to a different account, please log out first."
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
  # TODO: clean up this logic
  get '/volunteers/:username/edit' do
    if is_volunteer?(session)
      @volunteer = Volunteer.find_by(username: params[:username])

      if @volunteer.id == session[:user_id]
        erb :'volunteers/edit'
      else
        session[:message] = "You can only edit your own profile."
        redirect "/volunteers/#{@volunteer.username}"
      end
    else
      session[:message] = "You can only edit your own volunteer profile."
      redirect "/volunteers"
    end
  end

  patch '/volunteers/:username' do
    @volunteer = Volunteer.find_by(username: params[:username])

    # Check to ensure that the new password is a new one
    if username_already_taken?(params[:volunteer][:username]) && session[:user_id] != @volunteer.id
      session[:message] = "Sorry, the username you entered is already taken. Please edit with a different username."
    else
      @volunteer.update(params[:volunteer])
    end

    # TODO: check out to see if filling in blank-ly is allowed
    # TODO: only allow volunteers to update their username to one that is not yet taken
    redirect "/volunteers/#{@volunteer.username}"
  end

  # --- HELPER METHODS --- #

  helpers do

    def is_logged_in?(session)
      !!session[:user_id]
    end

    def username_already_taken?(username)
      !!Volunteer.find_by(username: username)
    end

    def is_member?(session)
      session[:user_type] == "member" && is_logged_in?(session)
    end

    def is_volunteer?(session)
      session[:user_type] == "volunteer" && is_logged_in?(session)
    end

  end

end

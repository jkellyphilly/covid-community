class MemberController < ApplicationController

  get '/members' do
    if is_logged_in?(session)
      @all_members = Member.all
      erb :'members/index'
    else
      session[:message] = "You're not logged in - log in here as a member or go to /volunteers/login to log in as a Volunteer!"
      redirect "/members/login"
    end
  end

  get '/members/signup' do
    if !is_logged_in?(session)
      erb :'members/signup'
    else
      session[:message] = "You're already logged in - please log out first if you'd like to sign up with a different account."
      redirect "/deliveries"
    end
  end

  post '/members/signup' do
    if username_already_taken?(params[:member][:username])
      session[:message] = "The username you entered is already being used by another member in our database. Please enter a new username."
      redirect "/members/signup"
    else
      @member = Member.new(params[:member])

      if @member.save
        session[:user_type] = "member"
        session[:user_id] = @member.id
        session[:message] = "Successfully created member profile - welcome, #{@member.name}!"
        redirect "/deliveries"
      else
        session[:message] = "Error: all non-optional fields must be filled out in order to sign up. Please try again."
        redirect "/members/signup"
      end
    end
  end

  get '/members/login' do
    if !is_logged_in?(session)
      erb :'members/login'
    else
      session[:message] = "You're already logged in as a #{session[:user_type]}. Please log out if you wish to log in to a different account."
      redirect "/deliveries"
    end
  end

  post '/members/login' do
    @member = Member.find_by(username: params[:username])

    if @member && @member.authenticate(params[:password])
      session[:user_id] = @member.id
      session[:user_type] = "member"
      redirect "/deliveries"
    else
      session[:message] = "Incorrect username or password. Please try again."
      redirect "members/login"
    end
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

  get '/members/:username/edit' do
    @member = Member.find_by(username: params[:username])

    if @member.id == session[:user_id] && is_member?(session)
      erb :'members/edit'
    else
      session[:message] = "You cannot edit another member's profile."
      redirect "/members/#{params[:username]}"
    end
  end

  patch '/members/:username' do
    @member = Member.find_by(username: params[:username])

    if username_already_taken?(params[:member][:username]) && session[:user_id] != Member.find_by(username: params[:member][:username]).id
      session[:message] = "The username you entered is already being used by another member in our database. Please edit with a different username."
      redirect "/members/#{params[:username]}/edit"
    elsif @member.update(params[:member])
      session[:message] = "Successfully updated member profile"
      redirect "/members/#{@member.username}"
    else
      session[:message] = "Error: all non-optional fields must be filled out in order to edit. Please try again."
      redirect "/members/#{params[:username]}/edit"
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

    def is_member?(session)
      session[:user_type] == "member" && is_logged_in?(session)
    end

    def is_volunteer?(session)
      session[:user_type] == "volunteer" && is_logged_in?(session)
    end

  end

end

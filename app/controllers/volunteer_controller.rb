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

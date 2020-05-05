class MemberController < ApplicationController

  get '/members' do
    "Shows full list of members"
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
    @member = Member.new(params[:member])

    if @member.save
      session[:user_type] = "member"
      session[:user_id] = @member.id
      redirect "/deliveries"
    else
      # TODO: add in flash message that all fields must be filled out correctly
      redirect "/members/signup"
    end
  end


  # --- HELPER METHODS ---

  helpers do

    def is_logged_in?(session)
      !!session[:user_id]
    end

  end

end

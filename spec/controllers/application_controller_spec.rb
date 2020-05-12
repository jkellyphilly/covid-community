require 'spec_helper'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to the Community.")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in and redirects to the welcome page" do
      member = Member.create(name: "Testy McTestFace", username: "test123", email: "test123@mailinator.com", address: "Testing Address", phone_number: "1234567890", allergies: "sesame", password: "McTestFace")

      params = {
        username: "test123",
        password: "McTestFace"
      }
      post '/login', params
      get '/logout'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/")
    end

    it 'redirects a user to the welcome page if a user tries to access the Homepage and is not logged in' do
      get '/deliveries'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/")
    end

  end

end

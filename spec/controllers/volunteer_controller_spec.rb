require 'spec_helper'

describe VolunteerController do

  describe "volunteer signup" do

    it 'loads the signup page' do
      get '/volunteers/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to homepage' do
      params = {
        :volunteer => {
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows",
          :phone_number => "2155144269",
          :name => "Skittles"
        }
      }
      post '/volunteers/signup', params

      expect(last_response.location).to include("/deliveries")
    end

    it 'does not let a volunteer sign up without a username' do
      params = {
        :volunteer => {
          :username => "",
          :email => "skittles@aol.com",
          :password => "rainbows",
          :phone_number => "2155144269",
          :name => "Skittles"
        }
      }
      post '/volunteers/signup', params
      expect(last_response.location).to include('/volunteers/signup')
    end

    it 'does not let a volunteer sign up without a password' do
      params = {
        :volunteer => {
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "",
          :phone_number => "2155144269",
          :name => "Skittles"
        }
      }
      post '/volunteers/signup', params
      expect(last_response.location).to include('/volunteers/signup')
    end

    it 'does not let a volunteer sign up without an email' do
      params = {
        :volunteer => {
          :username => "skittles123",
          :email => "",
          :password => "rainbows",
          :phone_number => "2155144269",
          :name => "Skittles"
        }
      }
      post '/volunteers/signup', params
      expect(last_response.location).to include('/volunteers/signup')
    end
  end

  describe "volunteer login" do
    it 'loads the login page' do
      get '/volunteers/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the homepage after login' do
      volunteer = Volunteer.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        phone_number: "1234567890",
        password: "McTestFace")

      params = {
        :username => "test123",
        :password => "McTestFace"
      }

      post '/volunteers/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to the Community.")
    end


    it 'does not let user view login page if already logged in' do
      volunteer = Volunteer.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        phone_number: "1234567890",
        password: "McTestFace")

      params = {
        :username => "test123",
        :password => "McTestFace"
      }
      post '/volunteers/login', params
      get '/volunteers/login'
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to the Community.")
    end
  end


  describe 'volunteer show page' do
    it 'shows all deliveries for a volunteer' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

        volunteer = Volunteer.create(
          name: "Volly McVolunteerFace",
          username: "test123",
          email: "test123@mailinator.com",
          phone_number: "1234567890",
          password: "McTestFace")

      params = {
        :username => "test123",
        :password => "McTestFace"
      }
      post '/volunteers/login', params

      delivery1 = Delivery.create(items: "milk", date: "tomorrow", status: "confirmed", member_id: member.id, volunteer_id: volunteer.id)
      delivery2 = Delivery.create(items: "cookies", date: "day after tomorrow", status: "confirmed", member_id: member.id, volunteer_id: volunteer.id)
      get "/volunteers/#{volunteer.username}"

      expect(last_response.body).to include("Delivery \#1")
      expect(last_response.body).to include("Delivery \#2")
      expect(last_response.body).to include("Edit your profile")
    end
  end

  describe 'volunteer directory' do
    context 'logged in' do
      it 'lets a user view the volunteer directory if logged in' do
        vol1 = Volunteer.create(
          name: "Testy McTestFace",
          username: "test123",
          email: "test123@mailinator.com",
          phone_number: "1234567890",
          password: "McTestFace")


        vol2 = Volunteer.create(
          name: "Testy McTestFace2",
          username: "test1234",
          email: "test1234@mailinator.com",
          phone_number: "1234567891",
          password: "McTestFace")

        visit '/volunteers/login'

        fill_in(:username, :with => "test123")
        fill_in(:password, :with => "McTestFace")
        click_button 'Log In'
        visit "/volunteers"
        expect(page.body).to include(vol1.name)
        expect(page.body).to include(vol2.name)
      end
    end

    context 'logged out' do
      it 'does not let a user view the volunteer directory if not logged in' do
        get '/volunteers'
        expect(last_response.location).to include("/volunteers/login")
      end
    end
  end


  describe 'editing volunteer profiles' do
    it 'lets a volunteer edit their own profile' do
      vol1 = Volunteer.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        phone_number: "1234567890",
        password: "McTestFace")

      visit '/volunteers/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/volunteers/test123/edit'
      expect(page.status_code).to eq(200)
      expect(page.body).to include(vol1.name)
      expect(page.body).to include("Updated name:")

      fill_in(:volunteer_name, :with => "My New Name")

      click_button 'Submit'
      expect(Volunteer.find_by(:name => "My New Name")).to be_instance_of(Volunteer)
      expect(Volunteer.find_by(:name => "Testy McTestFace")).to eq(nil)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a volunteer edit a different members profile' do
      vol1 = Volunteer.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        phone_number: "1234567890",
        password: "McTestFace")


      vol2 = Volunteer.create(
        name: "Testy McTestFace2",
        username: "test1234",
        email: "test1234@mailinator.com",
        phone_number: "1234567891",
        password: "McTestFace")

      visit '/volunteers/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/volunteers/test1234/edit'
      expect(page.current_path).not_to include("/edit")
      expect(page.body).to include("You can only edit your own profile.")
    end

    it 'does not let a volunteer edit their profile with a blank required field' do
      vol1 = Volunteer.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        phone_number: "1234567890",
        password: "McTestFace")

      visit '/volunteers/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/volunteers/test123/edit'

      fill_in(:volunteer_name, :with => "")
      fill_in(:volunteer_username, :with => "the-boss-man")

      click_button 'Submit'
      expect(Volunteer.find_by(:username => "the-boss-man")).to be(nil)
      expect(page.current_path).to eq("/volunteers/test123/edit")
    end

    it 'does not let a volunteer edit their profile to an already-taken username' do
      vol1 = Volunteer.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        phone_number: "1234567890",
        password: "McTestFace")


      vol2 = Volunteer.create(
        name: "Testy McTestFace2",
        username: "test1234",
        email: "test1234@mailinator.com",
        phone_number: "1234567891",
        password: "McTestFace")


      visit '/volunteers/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/volunteers/test123/edit'

      fill_in(:volunteer_username, :with => "test1234")

      click_button 'Submit'
      expect(Volunteer.find_by(:username => "test123")).to be_instance_of(Volunteer)
      expect(page.current_path).to eq("/volunteers/test123/edit")
    end

  end
end

require 'spec_helper'

describe MemberController do

  describe "member signup" do

    it 'loads the signup page' do
      get '/members/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to homepage' do
      params = {
        :member => {
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows",
          :phone_number => "2155144269",
          :address => "101 Main Street",
          :allergies => "shellfish",
          :name => "Skittles"
        }
      }
      post '/members/signup', params

      expect(last_response.location).to include("/deliveries")
    end

    it 'does not let a member sign up without a username' do
      params = {
        :member => {
          :username => "",
          :email => "skittles@aol.com",
          :password => "rainbows",
          :phone_number => "2155144269",
          :address => "101 Main Street",
          :allergies => "shellfish",
          :name => "Skittles"
        }
      }
      post '/members/signup', params
      expect(last_response.location).to include('/members/signup')
    end

    it 'does not let a member sign up without a password' do
      params = {
        :member => {
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "",
          :phone_number => "2155144269",
          :address => "101 Main Street",
          :allergies => "shellfish",
          :name => "Skittles"
        }
      }
      post '/members/signup', params
      expect(last_response.location).to include('/members/signup')
    end

    it 'does not let a member sign up without an email' do
      params = {
        :member => {
          :username => "skittles123",
          :email => "",
          :password => "rainbows",
          :phone_number => "2155144269",
          :address => "101 Main Street",
          :allergies => "shellfish",
          :name => "Skittles"
        }
      }
      post '/members/signup', params
      expect(last_response.location).to include('/members/signup')
    end
  end

  describe "member login" do
    it 'loads the login page' do
      get '/members/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the homepage after login' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      params = {
        :username => "test123",
        :password => "McTestFace"
      }

      post '/members/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to the Community.")
    end


    it 'does not let user view login page if already logged in' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      params = {
        :username => "test123",
        :password => "McTestFace"
      }
      post '/members/login', params
      get '/members/login'
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to the Community.")
    end
  end


  describe 'member show page' do
    it 'shows all deliveries for a member' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      params = {
        :username => "test123",
        :password => "McTestFace"
      }
      post '/members/login', params

      delivery1 = Delivery.create(items: "milk", date: "tomorrow", status: "new", member_id: member.id)
      delivery2 = Delivery.create(items: "cookies", date: "day after tomorrow", status: "new", member_id: member.id)
      get "/members/#{member.username}"

      expect(last_response.body).to include("Delivery \#1")
      expect(last_response.body).to include("Delivery \#2")
      expect(last_response.body).to include("Edit your profile")
    end
  end

  describe 'member directory' do
    context 'logged in' do
      it 'lets a user view the member directory if logged in' do
        member1 = Member.create(
          name: "Testy McTestFace",
          username: "test123",
          email: "test123@mailinator.com",
          address: "Testing Address",
          phone_number: "1234567890",
          allergies: "sesame",
          password: "McTestFace")


        member2 = Member.create(
          name: "Testy McTestFace2",
          username: "test1234",
          email: "test1234@mailinator.com",
          address: "Testing2 Address",
          phone_number: "1234567891",
          allergies: "sesame",
          password: "McTestFace")

        visit '/members/login'

        fill_in(:username, :with => "test123")
        fill_in(:password, :with => "McTestFace")
        click_button 'Log In'
        visit "/members"
        expect(page.body).to include(member1.name)
        expect(page.body).to include(member2.name)
      end
    end

    context 'logged out' do
      it 'does not let a user view the member directory if not logged in' do
        get '/members'
        expect(last_response.location).to include("/members/login")
      end
    end
  end


  describe 'editing member profiles' do
    it 'lets a member edit their own profile' do
      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/members/test123/edit'
      expect(page.status_code).to eq(200)
      expect(page.body).to include(member1.name)
      expect(page.body).to include("Updated name:")

      fill_in(:member_name, :with => "My New Name")

      click_button 'Submit'
      expect(Member.find_by(:name => "My New Name")).to be_instance_of(Member)
      expect(Member.find_by(:name => "Testy McTestFace")).to eq(nil)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a member edit a different members profile' do
      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")


      member2 = Member.create(
        name: "Testy McTestFace2",
        username: "test1234",
        email: "test1234@mailinator.com",
        address: "Testing2 Address",
        phone_number: "1234567891",
        allergies: "sesame",
        password: "McTestFace")

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit "members/test1234/edit"
      expect(page.current_path).not_to include("/edit")
      expect(page.body).to include("You cannot edit another member's profile.")
    end

    it 'does not let a member edit their profile with a blank required field' do
      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/members/test123/edit'

      fill_in(:member_name, :with => "")
      fill_in(:member_username, :with => "the-boss-man")

      click_button 'Submit'
      expect(Member.find_by(:username => "the-boss-man")).to be(nil)
      expect(page.current_path).to eq("/members/test123/edit")
    end

    # TODO: test for duplicate username
    it 'does not let a member edit their profile to an already-taken username' do
      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      member2 = Member.create(
        name: "Testy McTestFace2",
        username: "test1234",
        email: "test1234@mailinator.com",
        address: "Testing2 Address",
        phone_number: "1234567891",
        allergies: "sesame",
        password: "McTestFace")

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/members/test123/edit'

      fill_in(:member_username, :with => "test1234")

      click_button 'Submit'
      expect(Member.find_by(:username => "test123")).to be_instance_of(Member)
      expect(page.current_path).to eq("/members/test123/edit")
    end

  end
end

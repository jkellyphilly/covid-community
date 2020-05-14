require 'spec_helper'

describe DeliveryController do

  describe 'new action' do
    context 'logged in' do
      it 'lets a member view new delivery form if logged in' do
        member = Member.create(
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

        visit '/deliveries/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets member create a delivery request if they are logged in' do
        member = Member.create(
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

        visit '/deliveries/new'
        fill_in(:items, :with => "milk and cookies")
        fill_in(:date, :with => "July 4")
        click_button 'Submit'

        del = Delivery.find_by(:items => "milk and cookies")
        expect(del).to be_instance_of(Delivery)
        expect(del.member_id).to eq(member.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a member create a delivery requests from another member' do
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

        visit '/deliveries/new'

        fill_in(:items, :with => "tuna fish")
        fill_in(:date, :with => "tomorrow")
        click_button 'Submit'

        del = Delivery.find_by(:items => "tuna fish", :date => "tomorrow")
        expect(del).to be_instance_of(Delivery)
        expect(del.member_id).to eq(member1.id)
        expect(del.member_id).not_to eq(member2.id)
      end

      it 'does not let a member create a blank delivery request' do
        member = Member.create(
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

        visit '/deliveries/new'

        fill_in(:items, :with => "")
        fill_in(:date, :with=> "soon")
        click_button 'Submit'

        expect(Delivery.find_by(:items => "")).to eq(nil)
        expect(page.current_path).to eq("/deliveries/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new tweet form if not logged in as a member' do
        get '/deliveries/new'
        expect(last_response.location).to include("/deliveries")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single delivery' do

        member = Member.create(
          name: "Testy McTestFace",
          username: "test123",
          email: "test123@mailinator.com",
          address: "Testing Address",
          phone_number: "1234567890",
          allergies: "sesame",
          password: "McTestFace")

        del = Delivery.create(items: "milk and cookies", date: "tomorrow", member_id: member.id)

        visit '/members/login'
        fill_in(:username, :with => "test123")
        fill_in(:password, :with => "McTestFace")
        click_button 'Log In'

        visit "/deliveries/#{del.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete this request")
        expect(page.body).to include(del.items)
        expect(page.body).to include("Edit your requested delivery")
      end
    end

    context 'logged out' do
      it 'does not let a user view a delivery' do
        member = Member.create(
          name: "Testy McTestFace",
          username: "test123",
          email: "test123@mailinator.com",
          address: "Testing Address",
          phone_number: "1234567890",
          allergies: "sesame",
          password: "McTestFace")

        del = Delivery.create(items: "milk and cookies", date: "tomorrow", member_id: member.id)
        get "/deliveries/#{del.id}"
        expect(last_response.location).to include("/")
      end
    end
  end
  #
  # describe 'edit action' do
  #   context "logged in" do
  #     it 'lets a user view tweet edit form if they are logged in' do
  #       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  #       tweet = Tweet.create(:content => "tweeting!", :user_id => user.id)
  #       visit '/login'
  #
  #       fill_in(:username, :with => "becky567")
  #       fill_in(:password, :with => "kittens")
  #       click_button 'submit'
  #       visit '/tweets/1/edit'
  #       expect(page.status_code).to eq(200)
  #       expect(page.body).to include(tweet.content)
  #     end
  #
  #     it 'does not let a user edit a tweet they did not create' do
  #       user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  #       tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)
  #
  #       user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
  #       tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)
  #
  #       visit '/login'
  #
  #       fill_in(:username, :with => "becky567")
  #       fill_in(:password, :with => "kittens")
  #       click_button 'submit'
  #       visit "tweets/#{tweet2.id}"
  #       click_on "Edit Tweet"
  #       expect(page.status_code).to eq(200)
  #       expect(Tweet.find_by(:content => "look at this tweet")).to be_instance_of(Tweet)
  #       expect(page.current_path).to include('/tweets')
  #     end
  #
  #     it 'lets a user edit their own tweet if they are logged in' do
  #       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  #       tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
  #       visit '/login'
  #
  #       fill_in(:username, :with => "becky567")
  #       fill_in(:password, :with => "kittens")
  #       click_button 'submit'
  #       visit '/tweets/1/edit'
  #
  #       fill_in(:content, :with => "i love tweeting")
  #
  #       click_button 'submit'
  #       expect(Tweet.find_by(:content => "i love tweeting")).to be_instance_of(Tweet)
  #       expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
  #       expect(page.status_code).to eq(200)
  #     end
  #
  #     it 'does not let a user edit a text with blank content' do
  #       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  #       tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
  #       visit '/login'
  #
  #       fill_in(:username, :with => "becky567")
  #       fill_in(:password, :with => "kittens")
  #       click_button 'submit'
  #       visit '/tweets/1/edit'
  #
  #       fill_in(:content, :with => "")
  #
  #       click_button 'submit'
  #       expect(Tweet.find_by(:content => "i love tweeting")).to be(nil)
  #       expect(page.current_path).to eq("/tweets/1/edit")
  #     end
  #   end
  #
  #   context "logged out" do
  #     it 'does not load -- requests user to login' do
  #       get '/tweets/1/edit'
  #       expect(last_response.location).to include("/login")
  #     end
  #   end
  # end
  #
  # describe 'delete action' do
  #   context "logged in" do
  #     it 'lets a user delete their own tweet if they are logged in' do
  #       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  #       tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
  #       visit '/login'
  #
  #       fill_in(:username, :with => "becky567")
  #       fill_in(:password, :with => "kittens")
  #       click_button 'submit'
  #       visit 'tweets/1'
  #       click_button "Delete Tweet"
  #       expect(page.status_code).to eq(200)
  #       expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
  #     end
  #
  #     it 'does not let a user delete a tweet they did not create' do
  #       user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
  #       tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)
  #
  #       user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
  #       tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)
  #
  #       visit '/login'
  #
  #       fill_in(:username, :with => "becky567")
  #       fill_in(:password, :with => "kittens")
  #       click_button 'submit'
  #       visit "tweets/#{tweet2.id}"
  #       click_button "Delete Tweet"
  #       expect(page.status_code).to eq(200)
  #       expect(Tweet.find_by(:content => "look at this tweet")).to be_instance_of(Tweet)
  #       expect(page.current_path).to include('/tweets')
  #     end
  #   end
  #
  #   context "logged out" do
  #     it 'does not load let user delete a tweet if not logged in' do
  #       tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
  #       visit '/tweets/1'
  #       expect(page.current_path).to eq("/login")
  #     end
  #   end
  # end
end

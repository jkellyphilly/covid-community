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

      # TODO: add test in to ensure a volunteer can't create a delivery request
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

        del = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member.id)

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

      # TODO: add a test where a delivery has been confirmed (make sure the vol's name appears in the content on the page)
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

        del = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member.id)
        get "/deliveries/#{del.id}"
        expect(last_response.location).to include("/")
      end
    end
  end

  describe 'edit action' do
    it 'lets a member view delivery edit form if they are logged in' do
      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")
      del1 = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member1.id)

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/deliveries/1/edit'
      expect(page.status_code).to eq(200)
      expect(page.body).to include(del1.items)
    end

    it 'does not let a member edit a delivery requests they did not create' do
      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")
      del1 = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member1.id)

      member2 = Member.create(
        name: "Testy McTestFace2",
        username: "test1234",
        email: "test1234@mailinator.com",
        address: "Testing2 Address",
        phone_number: "1234567891",
        allergies: "sesame",
        password: "McTestFace")
      del2 = Delivery.create(items: "tuna fish", date: "day after tomorrow", status: "new", member_id: member2.id)

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'

      visit "deliveries/#{del2.id}/edit"

      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq("/deliveries/#{del2.id}")
      expect(page.body).to include("You must be logged in with a member account that owns this delivery request to edit details of the delivery.")
    end

    it 'lets a user edit their own tweet if they are logged in' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      del = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member.id)
      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/deliveries/1/edit'

      fill_in(:items, :with => "tuna fish")
      fill_in(:date, :with => "ASAP")

      click_button 'Submit'
      expect(Delivery.find_by(:items => "tuna fish", :date => "ASAP")).to be_instance_of(Delivery)
      expect(Delivery.find_by(:items => "milk and cookies", :date => "tomorrow")).to eq(nil)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a member edit a delivery request with blank content' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      del = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member.id)
      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit '/deliveries/1/edit'

      fill_in(:items, :with => "")
      fill_in(:date, :with => "May 22")

      click_button 'Submit'
      expect(Delivery.find_by(:date => "May 22")).to be(nil)
      expect(page.current_path).to eq("/deliveries/1/edit")
    end

    # TODO: create a test to make sure a volunteer can't see the /edit view
  end

  # TODO: update the volunteer tests
  # describe 'volunteer action' do
  #   it 'allows a volunteer to sign up for an unconfirmed delivery' do
  #
  #   end
  #
  #   it 'does not allow a volunteer to edit the status of a confirmed delivery' do
  #
  #   end
  #
  #   it 'allows a volunteer to mark a delivery as completed' do
  #
  #   end
  #
  #   it 'does not allow a member to access the volunteer view' do
  #
  #   end
  # end

  describe 'delete action' do

    it 'lets a member delete their own delivery request if they are logged in' do
      member = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")

      del = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member.id)
      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit 'deliveries/1'
      click_button "Delete this request"
      expect(page.status_code).to eq(200)
      expect(Delivery.find_by(:items => "milk and cookies", :date => "tomorrow")).to eq(nil)
    end

    it 'does not let a member delete a delivery request they did not create' do

      member1 = Member.create(
        name: "Testy McTestFace",
        username: "test123",
        email: "test123@mailinator.com",
        address: "Testing Address",
        phone_number: "1234567890",
        allergies: "sesame",
        password: "McTestFace")
      del1 = Delivery.create(items: "milk and cookies", date: "tomorrow", status: "new", member_id: member1.id)

      member2 = Member.create(
        name: "Testy McTestFace2",
        username: "test1234",
        email: "test1234@mailinator.com",
        address: "Testing2 Address",
        phone_number: "1234567891",
        allergies: "sesame",
        password: "McTestFace")
      del2 = Delivery.create(items: "tuna fish", date: "day after tomorrow", status: "new", member_id: member2.id)

      visit '/members/login'

      fill_in(:username, :with => "test123")
      fill_in(:password, :with => "McTestFace")
      click_button 'Log In'
      visit "deliveries/#{del2.id}"
      expect(page.body).not_to include("Delete this request")
      expect(page.status_code).to eq(200)
    end

    # TODO: add in a test to make sure that volunteers can't delete delivery requests
  end
end

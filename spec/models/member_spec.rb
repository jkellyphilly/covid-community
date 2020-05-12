require 'pry'
require 'spec_helper'

describe 'Member' do
  before do
    @member = Member.create(name: "Testy McTestFace", username: "test 123", email: "test123@mailinator.com", address: "Testing Address", phone_number: "1234567890", allergies: "sesame", password: "test")
    @volunteer = Volunteer.create(name: "Testy Volunteer", username: "vol_test", email: "iluv2volunteer@gmail.com", phone_number: "1112223345", password: "test")
    @delivery = Delivery.new(status: "new", items: "milk and cookies", date: "Test date")
    @member.deliveries << @delivery
    @member.save
    @delivery.save
  end
  # it 'can slug the username' do
  #   expect(@user.slug).to eq("test-123")
  # end
  #
  # it 'can find a user based on the slug' do
  #   slug = @user.slug
  #   expect(User.find_by_slug(slug).username).to eq("test 123")
  # end

  it 'has a secure password' do

    expect(@member.authenticate("dog")).to eq(false)

    expect(@member.authenticate("test")).to eq(@member)
  end

  it 'can keep track of all its new delivery requests' do

    expect(@member.new_deliveries.size).to eq(1)
    expect(@member.new_deliveries.first.items).to eq("milk and cookies")
  end

  it 'can keep track of all its confirmed delivery requests' do
    @volunteer.deliveries << @delivery
    @volunteer.save
    @delivery.status = "confirmed"
    @delivery.save

    expect(@member.confirmed_deliveries.size).to eq(1)
    expect(@member.confirmed_deliveries.first.items).to eq("milk and cookies")
    expect(@member.new_deliveries.size).to eq(0)
  end

  it 'can keep track of all its completed delivery requests' do
    @volunteer.deliveries << @delivery
    @volunteer.save
    @delivery.status = "completed"
    @delivery.save

    expect(@member.completed_deliveries.size).to eq(1)
    expect(@member.completed_deliveries.first.items).to eq("milk and cookies")
    expect(@member.confirmed_deliveries.size).to eq(0)
    expect(@member.new_deliveries.size).to eq(0)
  end
end

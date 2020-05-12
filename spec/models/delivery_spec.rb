require 'pry'
require 'spec_helper'

describe 'Delivery' do
  before do
    @member = Member.create(name: "Testy McTestFace", username: "test 123", email: "test123@mailinator.com", address: "Testing Address", phone_number: "1234567890", allergies: "sesame", password: "test")
    @volunteer = Volunteer.create(name: "Testy Volunteer", username: "vol_test", email: "iluv2volunteer@gmail.com", phone_number: "1112223345", password: "test")
    @delivery = Delivery.new(status: "new", items: "milk and cookies", date: "Test date")
    @member.deliveries << @delivery
    @member.save
    @delivery.save
  end

  it 'has a class method that can keep track of all new delivery requests' do

    expect(Delivery.new_requests.size).to eq(1)
    expect(Delivery.new_requests.first.items).to eq("milk and cookies")
  end

  it 'has a class method that can keep track of all confirmed delivery requests' do
    @volunteer.deliveries << @delivery
    @volunteer.save
    @delivery.status = "confirmed"
    @delivery.save

    expect(Delivery.confirmed_requests.size).to eq(1)
    expect(Delivery.confirmed_requests.first.items).to eq("milk and cookies")
    expect(Delivery.new_requests.size).to eq(0)
  end

  it 'has a class method that can keep track of all completed delivery requests' do
    @volunteer.deliveries << @delivery
    @volunteer.save
    @delivery.status = "completed"
    @delivery.save

    expect(Delivery.completed_requests.size).to eq(1)
    expect(Delivery.completed_requests.first.items).to eq("milk and cookies")
    expect(Delivery.confirmed_requests.size).to eq(0)
    expect(Delivery.new_requests.size).to eq(0)
  end
end

class Volunteer < ActiveRecord::Base
  has_secure_password

  has_many :deliveries
  has_many :members, through: :deliveries
end

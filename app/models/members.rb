class Member < ActiveRecord::Base
  has_secure_password

  has_many :deliveries
  has_many :volunteers, through: :deliveries
end

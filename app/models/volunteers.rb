class Volunteer < ActiveRecord::Base
  has_secure_password

  has_many :deliveries
  has_many :members, through: :deliveries

  validates :username, presence: true
  validates :name, presence: true
  validates :email, presence: true
  validates :phone_number, presence: true
end

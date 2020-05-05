class Member < ActiveRecord::Base
  has_secure_password

  has_many :deliveries
  has_many :volunteers, through: :deliveries

  validates :username, presence: true
  validates :address, presence: true
  validates :name, presence: true
  validates :email, presence: true
end

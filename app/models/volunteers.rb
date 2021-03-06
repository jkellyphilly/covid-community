class Volunteer < ActiveRecord::Base
  has_secure_password

  has_many :deliveries
  has_many :members, through: :deliveries

  validates :username, :name, :email, :phone_number, presence: true

  def confirmed_deliveries
    self.deliveries.select {|delivery| delivery.status == "confirmed"}
  end

  def completed_deliveries
    self.deliveries.select {|delivery| delivery.status == "completed"}
  end
end

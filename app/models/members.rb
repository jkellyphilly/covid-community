class Member < ActiveRecord::Base
  has_secure_password

  has_many :deliveries
  has_many :volunteers, through: :deliveries

  validates :username, :address, :name, :email, presence: true

  def new_deliveries
    self.deliveries.select {|delivery| delivery.status == "new" && !delivery.volunteer}
  end

  def confirmed_deliveries
    self.deliveries.select {|delivery| delivery.status == "confirmed" && delivery.volunteer}
  end

  def completed_deliveries
    self.deliveries.select {|delivery| delivery.status == "completed" && delivery.volunteer}
  end
end

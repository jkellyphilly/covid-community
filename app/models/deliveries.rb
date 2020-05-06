class Delivery < ActiveRecord::Base

  belongs_to :member
  belongs_to :volunteer

  validates :items, presence: true
  validates :date, presence: true

  def self.new_requests
    Delivery.all.select {|delivery| delivery.status == "new" && !delivery.volunteer}
  end

  def self.confirmed_requests
    Delivery.all.select {|delivery| delivery.status == "confirmed" && !!delivery.volunteer}
  end

  def self.completed_requests
    Delivery.all.select {|delivery| delivery.status == "completed" && !!delivery.volunteer}
  end

end

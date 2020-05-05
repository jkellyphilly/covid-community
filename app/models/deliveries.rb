class Delivery < ActiveRecord::Base

  belongs_to :member
  belongs_to :volunteer

end

class AddIdsToDeliveries < ActiveRecord::Migration[6.0]
  def change
    add_column :deliveries, :member_id, :integer
    add_column :deliveries, :volunteer_id, :integer
  end
end

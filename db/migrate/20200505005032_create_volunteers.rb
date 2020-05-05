class CreateVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :volunteers do |t|
      t.string :username
      t.string :name
      t.string :phone_number
    end
  end
end

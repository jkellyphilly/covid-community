class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.string :username
      t.string :name
      t.string :address
      t.string :phone_number
      t.string :allergies
    end
  end
end

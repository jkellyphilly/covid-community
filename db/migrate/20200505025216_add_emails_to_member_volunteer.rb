class AddEmailsToMemberVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :email, :string
    add_column :volunteers, :email, :string
  end
end

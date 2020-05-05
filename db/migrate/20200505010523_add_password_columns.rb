class AddPasswordColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :password_digest, :string
    add_column :volunteers, :password_digest, :string
  end
end

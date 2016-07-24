class AddActivationToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :activation_digest, :string, after: :remember_digest
    add_column :users, :activated, :Boolean, default: false, after: :activation_digest
    add_column :users, :activated_at, :datetime, after: :activated
  end
end

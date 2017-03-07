class AddAuthenticationTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :auth_token, :string, after: :reset_sent_at
    add_index :users, :auth_token, unique: true
  end
end

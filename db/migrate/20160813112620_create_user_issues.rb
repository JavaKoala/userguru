class CreateUserIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :user_issues do |t|
      t.integer :issue_id
      t.integer :user_id

      t.timestamps
    end
    add_index :user_issues, :issue_id
    add_index :user_issues, :user_id
    add_index :user_issues, [:issue_id, :user_id], unique: true
  end
end

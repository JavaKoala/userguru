class CreateIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.references :user, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :issues, [:user_id, :title]
  end
end

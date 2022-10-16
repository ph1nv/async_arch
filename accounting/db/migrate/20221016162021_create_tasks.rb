class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.uuid :public_id
      t.string :description
      t.string :jira_id
      t.string :status
      t.float :price_for_assign
      t.float :price_for_complete

      t.references :account

      t.timestamps
    end
  end
end

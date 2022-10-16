class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'

    create_table :tasks do |t|
      t.uuid :public_id, default: "gen_random_uuid()", null: false
      t.text :description

      t.references :account

      t.timestamps
    end

    execute <<-SQL
      CREATE TYPE task_statuses AS ENUM ('in_progress', 'done');
    SQL

    add_column :tasks, :status, :task_statuses, null: false, default: 'in_progress'
  end
end

class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :body
      t.string :twitter_status_id
      t.string :twitter_user_id

      t.timestamps :timestamps
    end

    add_index(:statuses, :twitter_status_id, :unique => true)
  end
end

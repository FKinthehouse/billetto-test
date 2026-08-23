class CreateVoteCounts < ActiveRecord::Migration[7.2]
  def change
    create_table :vote_counts do |t|
      t.integer :event_id, null: false
      t.integer :upvotes, default: 0, null: false
      t.integer :downvotes, default: 0, null: false

      t.timestamps

      t.index :event_id, unique: true
    end
  end
end

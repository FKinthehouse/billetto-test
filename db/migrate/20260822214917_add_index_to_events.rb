class AddIndexToEvents < ActiveRecord::Migration[7.2]
  def change
    add_index :events, :billetto_id
  end
end

class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :date
      t.text :image_url
      t.text :description
      t.integer :billetto_id

      t.timestamps
    end
  end
end

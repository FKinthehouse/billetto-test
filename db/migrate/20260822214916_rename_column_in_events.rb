class RenameColumnInEvents < ActiveRecord::Migration[7.2]
  def change
    rename_column :events, :image_url, :image_link
  end
end

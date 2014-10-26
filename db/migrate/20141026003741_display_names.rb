class DisplayNames < ActiveRecord::Migration
  def change
    add_column :users, :display_name, :string, :null => false
    rename_column :channels, :fancy_name, :display_name
  end
end

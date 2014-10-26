class RemoveNamesFromChannel < ActiveRecord::Migration
  def change
    remove_column :channels, :name, :string
    remove_column :channels, :display_name, :string
  end
end

class AddUserIdToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :user_id, :integer, :null => false
  end
end

class MigrationSwitchChannelUserOwnership < ActiveRecord::Migration
  def change
    remove_column :channels, :user_id
    add_column :users, :channel_id, :integer
  end
end

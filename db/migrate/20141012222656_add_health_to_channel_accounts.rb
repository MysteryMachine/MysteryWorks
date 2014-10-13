class AddHealthToChannelAccounts < ActiveRecord::Migration
  def change
    add_column :channel_accounts, :health, :integer, :null => false, :default => 6
    add_column :channel_accounts, :max_health, :integer, :null => false, :default => 6
  end
end

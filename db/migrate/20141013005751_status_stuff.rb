class StatusStuff < ActiveRecord::Migration
  def change
    rename_column :channels, :state, :status
    add_column :channel_accounts, :status, :string, :null => false, :default => "inactive"
  end
end

class CreateChannelAccount < ActiveRecord::Migration
  def change
    create_table :channel_accounts do |t|
      t.integer :balance, null: false, default: 10
      t.integer :channel_id, :null => false
      t.integer :user_id, :null => false
    end
    
    rename_column :bets, :user_id, :channel_account_id
    remove_column :bets, :channel_id
    change_column :bets, :channel_account_id, :integer, :null => false
    change_column :bets, :amount, :integer, :null => false
    change_column :bets, :enemy_id, :integer, :null => false
    change_column :bets, :status, :string, :null => false, :default => "open"
    
    remove_column :users, :balance
    
    change_column :channels, :name, :string, :null => false
    change_column :channels, :state, :string, :null => false, :default => "inactive"
  end
end

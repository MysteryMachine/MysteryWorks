class AddStatusToBet < ActiveRecord::Migration
  def change
    add_column :bets, :status, :string
  end
end

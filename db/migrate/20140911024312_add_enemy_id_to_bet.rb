class AddEnemyIdToBet < ActiveRecord::Migration
  def change
    add_column :bets, :enemy_id, :integer
  end
end

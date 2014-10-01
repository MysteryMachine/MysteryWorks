class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.integer :user_id
      t.integer :channel_id
      t.integer :amount

      t.timestamps
    end
  end
end

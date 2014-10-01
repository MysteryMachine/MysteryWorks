class ChannelAccount < ActiveRecord::Base
  has_many :bets
  
  validates :channel_id, :numericality => { :greater_than => 0 }
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }
  
  def pay_out(amount)
    self.balance += amount
    self.save
  end
  
  def bet(amount, enemy_id)
    if amount < balance
      bet = Bet.new(:amount => amount, :enemy_id => enemy_id, :channel_account_id => id)
      self.balance -= amount
      if bet.save
        self.save
      else
        self.errors.add(:balance, "error creating bet")
      end
    else
      self.errors.add(:balance, "cannot bet more than your current balance")
    end
  end
end

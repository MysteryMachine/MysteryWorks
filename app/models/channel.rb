class Channel < ActiveRecord::Base
  include ChannelHelper
  validates :state, :inclusion => { :in => VALID_STATES }
  
  has_many :channel_accounts
  has_many :bets, :through => :channel_accounts
  
  def set_inactive
    invalidate_bets
    self.state = INACTIVE
    self.save
  end
  
  def open_betting
    self.state = BETTING_OPEN
    self.save
  end
  
  def close_betting
    self.state = BETTING_CLOSED
    self.save
  end
  
  def complete_betting(enemy_id)
    pay_out(enemy_id)
    self.state = INACTIVE
    self.save
  end
  
  def pot
    bets.inject(0){ |sum, bet| bet.amount + sum }
  end
  
  private
  
  def pay_out(enemy_id)
    winners = bets.winners(enemy_id)
    losers = bets.losers(enemy_id)
    award = pot / winners.length
    
    winners.each { |b| b.pay_out(award) }
    losers.each { |b| b.close() }
    
    reload
  end
  
  def invalidate_bets
    bets.all.each do |bet|
      bet.invalidate
    end
  end
end

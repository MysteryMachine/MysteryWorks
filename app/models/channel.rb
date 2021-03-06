# Channels are where bets are sent to. They can open bets, 
# close bets, invalidate bets, and complete bets. When completing
# a bet, a channel may invalidate all bets if no one wins, or pay
# them out if someone does. After completing bets, all channel
# accounts are returned to their default states
# Channels are heavily based on automata.
class Channel < ActiveRecord::Base
  include ChannelHelper
  validates :status, :inclusion => { :in => VALID_STATES }
  
  has_one :user
  has_many :channel_accounts
  has_many :bets, :through => :channel_accounts
  
  # ACTIONS
  
  def set_inactive
    begin
      transaction do
        invalidate_bets
        self.status = INACTIVE
        self.save!
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
  
  def open_betting
    self.status = BETTING_OPEN
    self.save
  end
  
  def close_betting
    self.status = BETTING_CLOSED
    self.save
  end
  
  def complete_betting(enemy_id)
    begin
      transaction do
        pay_out(enemy_id)
        deactivate
      end
      
      reload
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
  
  # HELPERS
  def find_channel_account(user)
    possible_accounts = channel_accounts.where(:user_id => user.id)
    if possible_accounts.length >= 1
      possible_accounts.first
    else
      nil
    end
  end
  
  def can_set_inactive?
    true
  end
  
  def can_open_betting?
    status == INACTIVE
  end
  
  def can_close_betting?
    status == BETTING_OPEN
  end
  
  def can_complete_betting?
    status == BETTING_CLOSED
  end
  
  def active_bets
    bets.active
  end
  
  def whole_pot
    pot(active_bets)
  end
  
  def pot(bet_group)
    bet_group.inject(0){ |sum, bet| bet.amount + sum }
  end
  
  def name
    user.name
  end
  
  def display_name
    user.display_name
  end
  
  private
  
  def deactivate
    channel_accounts.each { |channel_account| channel_account.deactivate }
    self.status = INACTIVE
    self.save!
  end
  
  # Selects all winners and losers. If someone won, calculate the pot, and award
  # a proportional amount of it to every winner. Close the bets of the losers
  # If no one won, invalidate all the bets
  def pay_out(enemy_id)
    winners = bets.winners(enemy_id)
    losers = bets.losers(enemy_id)
    
    winner_pot = pot(winners)
    total = winner_pot + pot(losers)
    
    if winners.length > 0
      winners.each { |b| b.pay_out(winner_pot, total) }
      losers.each { |b| b.close }
    else
      invalidate_bets
    end
  end
  
  def invalidate_bets
    active_bets.each do |bet|
      bet.invalidate
    end
  end
end

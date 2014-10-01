class Bet < ActiveRecord::Base
  include BetHelper
  
  belongs_to :channel_account
  belongs_to :channel, :through => :channel_account

  validates :enemy_id, :numericality => { :greater_than => 0 }
  validates :channel_account_id, :numericality => { :greater_than => 0 }
  validates :amount, :inclusion => { :in => VALID_BETS }
  validates :status, :inclusion => { :in => VALID_STATUSES }
  
  scope :active, lambda {where(:status => OPEN)}
  scope :winners, lambda {|enemy_id| where(:enemy_id => enemy_id).active}
  scope :losers, lambda {|enemy_id| where("enemy_id != ?", enemy_id).active}
  
  def pay_out(amount)
    channel_account.pay_out(amount)
    self.status = PAID_OUT
    self.save
  end
  
  def invalidate
    channel_account.pay_out(amount)
    self.status = INVALIDATED
    self.save
  end
  
  def close
    self.status = CLOSED
    self.save
  end
end

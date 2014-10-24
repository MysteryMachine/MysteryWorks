# A finite automata. From an inactive state, they can rest to obtain random
# amounts of health, donate_blood to lose a health and gain money back,
# or bet, which sets aside some money and may or may not return money back
# to the channel_account later. When it deactivates, it resets to an inactive
# state
class ChannelAccount < ActiveRecord::Base
  include ChannelAccountHelper
  
  has_many :bets
  belongs_to :channel
  belongs_to :user
  
  validates :channel_id, :numericality => { :greater_than => 0 }
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }
  validates :max_health, :numericality => { :greater_than => 5, :less_than_or_equal_to => 20 }
  validates :health, :numericality => { :greater_than => 0 }
  validates :status, :inclusion => { :in => VALID_STATUSES }
  validate :health_correct
  def health_correct
   self.errors.add(:health, "too much health") if health > max_health
  end
  
  # ACTIONS
  
  # Adds a randomly determined amount of health to health, reaching,
  # at most, max_health. Sets status to resting.
  def rest
    self.status = STATUS_RESTING
    self.health += select_rest
    self.health = max_health if health > max_health
    self.save
  end
  
  # Subtracts 1 health from self and awards self a random amount of
  # money. Sets status to donating_blood
  def donate_blood  
    self.status = STATUS_DONATING_BLOOD
    self.health -= 1
    self.balance += select_blood_machine
    self.save
  end
  
  # Subtracts amount from balance, and creates a Bet for that enemy
  # and channel_account. Sets status to betting
  def bet(amount, enemy_id)
    begin
      transaction do
        new_bet = Bet.new(:amount => amount, :enemy_id => enemy_id, :channel_account_id => id)
        self.bets << new_bet
        self.balance -= amount
        self.status = STATUS_BETTING 
        
        new_bet.save!
        self.save!
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
  
  # HELPERS
  def can_rest?
    self.status == STATUS_INACTIVE
  end
  
  def can_donate_blood?
    self.status == STATUS_INACTIVE
  end
  
  def can_bet?
    self.status == STATUS_INACTIVE
  end
  
  def pay_out(amount)
    self.balance += amount
    self.save!
  end
  
  def deactivate
    self.status = STATUS_INACTIVE
    self.save!
  end
end

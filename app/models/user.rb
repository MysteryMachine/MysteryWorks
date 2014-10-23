class User < ActiveRecord::Base
  devise :rememberable
  devise :omniauthable, :omniauth_providers => [:twitch]
  
  has_many :channel_accounts
  belongs_to :channel
  
  validates :channel_id, :uniqueness => true, :allow_nil => true
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
  
  def request_channel
    if channel.nil?
      channel = Channel.new(:name => self.name)
      self.channel = channel
      channel.save
    else
      false
    end
  end
  
  def self.new_with_session(params, session)
    super.tap {|n|}
  end
  
  def owns_channel_account?(channel_account)
    channel_account.user_id == id
  end
  
  def owns_channel?(channel)
    channel.id == channel_id
  end
  
  def can_rest?(channel_account)
    owns_channel_account?(channel_account) && channel_account.can_rest?
  end
  
  def can_donate_blood?(channel_account)
    owns_channel_account?(channel_account) && channel_account.can_donate_blood?
  end
  
  def can_bet?(channel_account)
    owns_channel_account?(channel_account) && channel_account.can_bet?
  end
  
  def can_set_inactive?(channel)
    owns_channel?(channel) && channel.can_set_inactive?
  end
  
  def can_open_betting?(channel)
    owns_channel?(channel) && channel.can_open_betting?
  end
  
  def can_close_betting?(channel)
    owns_channel?(channel) && channel.can_close_betting?
  end
  
  def can_complete_betting?(channel)
    owns_channel?(channel) && channel.can_complete_betting?
  end
end

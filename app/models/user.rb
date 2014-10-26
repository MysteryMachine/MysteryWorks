# Users are CanCan objects that are used as our sessions thing
# They own channel accounts, and can request a channel for
# themselves and channel_accounts for other users' channels
class User < ActiveRecord::Base
  devise :rememberable
  devise :omniauthable, :omniauth_providers => [:twitch]
  
  has_many :channel_accounts
  belongs_to :channel
  
  validates :channel_id, :uniqueness => true, :allow_nil => true
  validates :name, :uniqueness => true, :presence => true
  validates :display_name, :uniqueness => true, :presence => true
  
  # An OAuth magic function stolen from the wiki. Sets the provider, uid
  # name, and email of a User and creates it if a User doesn't exist, other
  # wise, it just selects the existing user
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      user.display_name = auth.info.display_name
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
  
  # Creates a channel account for a given channel
  def channel_account_for(channel)
    ca = ChannelAccount.new(:user_id => id, :channel_id => channel.id)
    ca.save
    self.channel_accounts << ca
  end
  
  # If the user does not have a channel, create it
  def request_channel
    if channel.nil?
      begin
        transaction do
          channel = Channel.new
          channel.save!
          self.channel_id = channel.id
          self.save!
        end
      rescue ActiveRecord::RecordInvalid
        false
      end
    else
      false
    end
  end
  
  # Sessions magic copied from the wiki
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

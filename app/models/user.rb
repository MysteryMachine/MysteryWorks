class User < ActiveRecord::Base
  devise :rememberable
  devise :omniauthable, :omniauth_providers => [:twitch]
  
  has_many :channel_accounts
  
  validates :name, :presence => true
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
  
  def self.new_with_session(params, session)
    super.tap {|n|}
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable
  devise :omniauthable, :omniauth_providers => [:twitch]
end

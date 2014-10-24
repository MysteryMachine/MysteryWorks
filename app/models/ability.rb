class Ability
  include CanCan::Ability

  def initialize(user)
    can :show, ChannelAccount
    can :show, Channel
    
    if !user.nil?
      can :rest, ChannelAccount do |channel_account| user.can_rest?(channel_account) end
      can :donate_blood, ChannelAccount do |channel_account| user.can_donate_blood?(channel_account) end
      can :bet, ChannelAccount do |channel_account| user.can_bet?(channel_account) end
            
      can :create, Channel 
      can :set_inactive, Channel do |channel| user.can_set_inactive?(channel) end
      can :open_betting, Channel do |channel| user.can_open_betting?(channel) end
      can :close_betting, Channel do |channel| user.can_close_betting?(channel) end
      can :complete_betting, Channel do |channel| user.can_complete_betting?(channel) end
    end
  end
end

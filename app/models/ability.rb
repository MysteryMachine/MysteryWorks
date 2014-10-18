class Ability
  include CanCan::Ability

  def initialize(user)
    can :rest, ChannelAccount {|channel_account| user.can_rest?(channel_account)}
    can :donate_blood, ChannelAccount {|channel_account| user.can_donate_blood?(channel_account)}
    can :bet, ChannelAccount {|channel_account| user.can_bet?(channel_account)}
    can :show, ChannelAccount
    
    can :set_inactive, Channel {|channel| user.can_set_inactive?(channel)}
    can :open_betting, Channel {|channel| user.can_open_betting?(channel)}
    can :close_betting, Channel {|channel| user.can_close_betting?(channel)}
    can :complete_betting, Channel {|channel| user.can_complete_betting?(channel)}
    can :show, Channel
  end
end

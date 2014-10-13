FactoryGirl.define do
  factory :channel do
    name "mantron"
    user
    
    trait :with_bets do
      after(:create) do |channel|
        channel_account = create(:channel_account, :channel => channel, :status => "betting")
        channel_account_loser = create(:channel_account, :channel => channel, :status => "betting")
        channel_account_closed = create(:channel_account, :channel => channel, :status => "inactive")
        channel_account_invalidated = create(:channel_account, :channel => channel, :status => "inactive")
        channel_account_paid_out = create(:channel_account, :channel => channel, :status => "inactive")
        channel_account_resting = create(:channel_account, :status => "resting")
        channel_account_donating = create :channel_account, :status => "donating_blood"
        
        channel_account.bets << create(:bet, :channel_account => channel_account)
        channel_account_loser.bets << create(:bet, :loser, :channel_account => channel_account_loser)
        channel_account_closed.bets << create(:bet, :closed, :channel_account => channel_account_closed)
        channel_account_invalidated.bets << create(:bet, :invalidated, :channel_account => channel_account_invalidated)
        channel_account_paid_out.bets << create(:bet, :paid_out, :channel_account => channel_account_paid_out)
        
        channel.channel_accounts << channel_account
        channel.channel_accounts << channel_account_loser
        channel.channel_accounts << channel_account_closed
        channel.channel_accounts << channel_account_invalidated
        channel.channel_accounts << channel_account_paid_out
        channel.channel_accounts << channel_account_resting
        channel.channel_accounts << channel_account_donating
      end
    end
  end
end

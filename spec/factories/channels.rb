FactoryGirl.define do
  factory :channel do
    trait :with_bets do
      after(:create) do |channel|
        channel.channel_accounts << create(:channel_account, :with_winning_bet, :channel => channel)
        channel.channel_accounts << create(:channel_account, :with_loser_bet, :channel => channel)
        channel.channel_accounts << create(:channel_account, :with_closed_bet, :channel => channel)
        channel.channel_accounts << create(:channel_account, :with_invalidated_bet, :channel => channel)
        channel.channel_accounts << create(:channel_account, :with_paid_out_bet, :channel => channel)
        channel.channel_accounts << create(:channel_account, :resting, :channel => channel)
        channel.channel_accounts << create(:channel_account, :donating_blood, :channel => channel)
      end
    end
  end
end

FactoryGirl.define do
  factory :channel_account do
    balance 10
    status "inactive"
    channel
    user
    
    trait :with_winning_bet do
      status "betting"
      after(:create) do |channel_account|
        channel_account.bets << create(:bet, :channel_account => channel_account)
      end
    end
    
    trait :with_loser_bet do
      status "betting"
      after(:create) do |channel_account|
        channel_account.bets << create(:bet, :loser, :channel_account => channel_account)
      end
    end
    
    trait :with_closed_bet do
      after(:create) do |channel_account|
        channel_account.bets << create(:bet, :closed, :channel_account => channel_account)
      end
    end
    
    trait :with_invalidated_bet do
      after(:create) do |channel_account|
        channel_account.bets << create(:bet, :invalidated, :channel_account => channel_account)
      end
    end
    
    trait :with_paid_out_bet do
      after(:create) do |channel_account|
        channel_account.bets << create(:bet, :paid_out, :channel_account => channel_account)
      end
    end
    
    trait :resting do
      status "resting"
    end
    
    trait :donating_blood do
      status "donating_blood"
    end
  end
end

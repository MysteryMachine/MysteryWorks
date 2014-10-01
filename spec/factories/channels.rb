FactoryGirl.define do
  factory :channel do
    name "mantron"
    state "betting_open"
    
    trait :with_bets do
      after(:create) do |channel|
        channel.bets << create(:bet, :channel => channel)
        channel.bets << create(:bet, :loser, :channel => channel)
        channel.bets << create(:bet, :closed, :channel => channel)
        channel.bets << create(:bet, :invalidated, :channel => channel)
        channel.bets << create(:bet, :paid_out, :channel => channel)
      end
    end
  end
end

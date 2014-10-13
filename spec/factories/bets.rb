FactoryGirl.define do
  factory :bet do
    channel_account
    enemy_id 1
    status "open"
    amount 10
    
    trait :loser do
      enemy_id 2
    end
    
    trait :invalidated do
      status "invalidated"
    end
    
    trait :closed do
      status "closed"
    end
    
    trait :paid_out do
      status "paid_out"
    end
  end
end

FactoryGirl.define do
  sequence(:email) { |n| "#{n}@test.com" }
  
  factory :user do
    name "mysterymachinesa"
    balance 10
    email 
  end
end

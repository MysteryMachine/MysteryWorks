FactoryGirl.define do
  sequence(:email) { |n| "#{n}@test.com" }
  
  factory :user do
    name "mysterymachinesa"
    email 
  end
end

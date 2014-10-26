FactoryGirl.define do
  sequence(:email) { |n| "#{n}@test.com" }
  sequence(:name) { |n| "name#{n}" }
  sequence(:display_name) { |n| "Name#{n}" }
  
  factory :user do
    name
    display_name
    email 
  end
end

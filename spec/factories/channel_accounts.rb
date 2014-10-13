FactoryGirl.define do
  factory :channel_account do
    balance 10
    channel
    user
  end
end

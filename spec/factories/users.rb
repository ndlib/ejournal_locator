FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "test#{n}" }
    email { "#{username}@example.com"}
  end
end

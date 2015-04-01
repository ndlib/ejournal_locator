FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "test#{n}" }
    email { "#{username}@example.com"}
    created_at { Time.now }
    updated_at { Time.now }
  end
end

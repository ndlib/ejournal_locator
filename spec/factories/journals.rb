FactoryGirl.define do
  TITLES = ["Science","Nature","Harvard Business Review", "New York Times","American Political Science Review","International Security","Foreign Affairs"]
  factory :journal do
    sequence(:sfx_id) { |n| ((rand(9000000000) + 1000000000) * 1000) + n }
    sequence(:title) { |n| TITLES[n] || "Journal #{n}" }
    sequence(:issn) { |n| 10000000 + n }
  end
end

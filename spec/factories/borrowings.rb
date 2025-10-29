FactoryBot.define do
  factory :borrowing do
    association :user, factory: [ :user, :member ]
    association :book
    borrowed_at { Time.current }
    due_date { Time.current + 14.days }
    returned_at { nil }

    trait :returned do
      returned_at { Time.current }
    end

    trait :overdue do
      due_date { 1.day.ago }
      returned_at { nil }
    end
  end
end

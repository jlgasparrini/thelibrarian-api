FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    sequence(:isbn) { |n| "978-#{n.to_s.rjust(10, '0')}" }
    total_copies { 5 }
    available_copies { 5 }

    trait :unavailable do
      available_copies { 0 }
    end

    trait :limited do
      total_copies { 2 }
      available_copies { 1 }
    end
  end
end

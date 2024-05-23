# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "user#{SecureRandom.hex}@email.com" }
    password { Faker::Internet.password }

    factory :admin, class: User::Admin do
      type { 'User::Admin' }
    end

    factory :merchant, class: User::Merchant do
      type { 'User::Merchant' }
    end
  end
end

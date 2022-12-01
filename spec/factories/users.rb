FactoryBot.define do
  factory :user do
    email { "user#{SecureRandom.hex}@email.com" }

    factory :admin, class: User::Admin do
      type { "User::Admin" }
    end

    factory :merchant, class: User::Merchant do
      type { "User::Merchant" }
    end
  end
end

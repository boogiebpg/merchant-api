# frozen_string_literal: true

FactoryBot.define do
  factory :authorize_transaction, class: Transaction::Authorize do
    before(:create) do |transaction|
      transaction.user = create(:merchant, email: transaction.customer_email, status: User::Merchant::STATUSES[:active])
    end

    amount { rand(10_000) / 100.0 }
    uuid { SecureRandom.uuid }
    customer_email { Faker::Internet.email }
    status { :approved }
  end

  factory :charge_transaction, class: Transaction::Charge do
    before(:create) do |transaction|
      transaction.user = create(:merchant, email: transaction.customer_email, status: User::Merchant::STATUSES[:active])
    end

    amount { rand(10_000) / 100.0 }
    uuid { SecureRandom.uuid }
    customer_email { Faker::Internet.email }
    status { :approved }
  end
end

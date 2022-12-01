FactoryBot.define do
  factory :authorize_transaction, class: Transaction::Authorize do
    before(:create) do |transaction|
      transaction.user = create(:merchant, email: transaction.customer_email)
    end

    amount { 50 }
    uuid { SecureRandom.uuid }
    customer_email { Faker::Internet.email }
    status { :approved }

  end
end

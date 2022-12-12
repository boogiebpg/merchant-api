# frozen_string_literal: true

class TransactionMerchantStatusValidator < ActiveModel::Validator
  def validate(record)
    return if record.user&.status == User::Merchant::STATUSES[:active]

    record.errors.add :user, 'Merchant should be active!'
  end
end

# frozen_string_literal: true

class TransactionMerchantStatusValidator < ActiveModel::Validator
  def validate(record)
    unless record.user.status == User::Merchant::STATUSES[:active]
      record.errors.add :amount, 'Merchant should be active!'
    end
  end
end

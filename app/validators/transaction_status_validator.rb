# frozen_string_literal: true

class TransactionStatusValidator < ActiveModel::Validator
  def validate(record)
    if record.amount && record.type == 'Transaction::Reversal'
      record.errors.add :amount, 'Incorrect value!'
    elsif record.amount.to_f <= 0 && record.type != 'Transaction::Reversal'
      record.errors.add :amount, 'Incorrect value!'
    end
  end
end

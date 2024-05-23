# frozen_string_literal: true

class TransactionParentValidator < ActiveModel::Validator
  def validate(record)
    return unless record.transaction_id

    parent_transaction = record.parent_transaction
    unless parent_transaction
      record.errors.add :transaction_id, 'Parent transaction is incorrect!'
      return
    end
    if parent_transaction.type != record.type.constantize::ALLOWED_PARENT
      record.errors.add :transaction_id, 'Parent transaction type is incorrect!'
    elsif !Transaction::CORRECT_PARENT_STATUSES.include?(parent_transaction.status)
      record.status = Transaction::STATUSES[:error]
    end
  end
end

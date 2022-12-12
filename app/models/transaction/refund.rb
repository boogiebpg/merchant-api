# frozen_string_literal: true

class Transaction::Refund < Transaction
  ALLOWED_PARENT = 'Transaction::Charge'
end

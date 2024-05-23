# frozen_string_literal: true

class Transaction::Reversal < Transaction
  ALLOWED_PARENT = 'Transaction::Authorize'
end

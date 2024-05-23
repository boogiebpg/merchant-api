# frozen_string_literal: true

class Transaction::Charge < Transaction
  ALLOWED_PARENT = 'Transaction::Authorize'
end

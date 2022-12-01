# frozen_string_literal: true

class User::Merchant < User
  STATUSES = {
    active: 0,
    inactive: 1
  }.freeze
end

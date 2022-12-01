# frozen_string_literal: true

namespace :transactions do
  desc 'Remove Transactions Older than an hour'
  task remove: :environment do
    Transaction.obsolete.destroy_all
  end
end

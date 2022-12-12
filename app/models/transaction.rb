# frozen_string_literal: true

class Transaction < ApplicationRecord
  include ActiveModel::Validations

  belongs_to :user
  belongs_to :parent_transaction, class_name: 'Transaction', foreign_key: 'transaction_id', optional: true
  has_one :child_transaction, class_name: 'Transaction', foreign_key: 'transaction_id',
                              dependent: :restrict_with_exception

  STATUSES = {
    approved: 0,
    reversed: 1,
    refunded: 2,
    error: 3
  }.freeze

  CORRECT_PARENT_STATUSES = [
    STATUSES[:approved],
    STATUSES[:refunded]
  ].freeze

  enum status: STATUSES

  validates_with UuidValidator
  validates_with TransactionStatusValidator
  validates_with TransactionMerchantStatusValidator
  validates_with TransactionParentValidator
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: STATUSES.keys.map(&:to_s) }
  validates :type,
            inclusion: { in: %w[Transaction::Authorize Transaction::Charge Transaction::Refund Transaction::Reversal] }

  scope :obsolete, -> { where('created_at < ?', Time.current - 1.hour) }
end

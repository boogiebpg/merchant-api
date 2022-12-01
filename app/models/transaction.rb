# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :user

  STATUSES = {
    approved: 0,
    reversed: 1,
    refunded: 2,
    error: 3
  }.freeze

  enum status: STATUSES

  include ActiveModel::Validations
  validates_with UuidValidator
  validates_with TransactionStatusValidator
  validates_with TransactionMerchantStatusValidator
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: STATUSES.keys.map(&:to_s) }

  scope :obsolete, -> { where('created_at < ?', Time.current - 1.hour) }

  def initialize(*args)
    raise "Can't create a Transaction" if instance_of?(Transaction)

    super
  end
end

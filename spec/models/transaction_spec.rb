# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:parent_transaction).optional(true) }
    it { should have_one(:child_transaction).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    it {
      should validate_inclusion_of(:type).in_array(%w[Transaction::Authorize Transaction::Charge Transaction::Refund
                                                      Transaction::Reversal])
    }
    it { should define_enum_for(:status).with_values(%w[approved reversed refunded error]) }
    it { should allow_value('test@email.com').for(:customer_email) }
    it { should_not allow_value('test').for(:customer_email) }
    it { should_not allow_value(nil).for(:customer_email) }
  end
end

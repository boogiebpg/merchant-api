# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_secure_password(:password) }
    it { should have_many(:transactions) }
  end

  describe 'validations' do
    it { should allow_value('test@email.com').for(:email) }
    it { should_not allow_value('test').for(:email) }
    it { should_not allow_value(nil).for(:email) }
  end
end

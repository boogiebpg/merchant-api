class TransactionCreator < ApplicationService
  attr_accessor :data, :format, :transaction_data

  def initialize(data, format)
    @data = data
    @format = format
  end

  def call
    case format
    when :json
      process_json
    when :xml
      process_xml
    else
      raise "Not Implemented!"
    end
  end

  private

  def process_json
    @transaction_data = JSON.parse(data).symbolize_keys
    create_transaction!
  end

  def process_xml
    doc = Nokogiri::XML(data)
    transaction = doc.at_xpath('//transaction')
    @transaction_data = {
      uuid: transaction.at_xpath('//uuid')&.content,
      amount: transaction.at_xpath('//amount')&.content,
      status: transaction.at_xpath('//status')&.content,
      customer_email: transaction.at_xpath('//customer-email')&.content,
      customer_phone: transaction.at_xpath('//customer-phone')&.content,
      type: transaction.at_xpath('//type').content,
    }
    create_transaction!
  end

  def create_transaction!
    merchant = User.find_by(email: transaction_data[:customer_email])
    merchant.transactions.create!(transaction_data)
  rescue ActiveRecord::RecordInvalid
    # WIP
  end
end

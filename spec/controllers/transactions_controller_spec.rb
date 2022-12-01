require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:authorize_transaction) do
    build(:authorize_transaction)
  end

  let(:authorize_transaction_with_inactive_merchant) do
    build(:authorize_transaction)
  end

  let!(:merchant) do
    create(
      :merchant,
      email: authorize_transaction.customer_email,
      status: User::Merchant::STATUSES[:active]
    )
  end

  let!(:inactive_merchant) do
    create(
      :merchant,
      email: authorize_transaction_with_inactive_merchant.customer_email,
      status: User::Merchant::STATUSES[:inactive]
    )
  end

  let(:transaction_json_data) do
    authorize_transaction
      .attributes
      .slice(
        "uuid",
        "amount",
        "status",
        "customer_email",
        "customer_phone",
        "type",
      )
      .to_json
  end

  let(:transaction_with_inactive_merchant_json_data) do
    authorize_transaction_with_inactive_merchant
      .attributes
      .slice(
        "uuid",
        "amount",
        "status",
        "customer_email",
        "customer_phone",
        "type",
      )
      .to_json
  end

  let(:transaction_xml_data) do
    authorize_transaction
      .attributes
      .slice(
        "uuid",
        "amount",
        "status",
        "customer_email",
        "customer_phone",
        "type",
      )
      .to_xml(root: "transaction")
  end

  let(:parsed_json_body) do
    JSON.parse(response.body).deep_symbolize_keys
  end

  describe "#create" do
    context 'when create transaction for inactive merchant' do
      # WIP
      # it 'responds with 422' do
      #   post :create, format: :json, params: { transaction: transaction_with_inactive_merchant_json_data }
      #   expect(response.status).to eq(422)
      # end
    end

    context 'when create transaction with correct json params' do
      it 'responds with 200' do
        post :create, format: :json, params: { transaction: transaction_json_data }
        expect(response.status).to eq(200)
      end

      it 'creates transaction record with correct values' do
        expect do
          post :create, format: :json, params: { transaction: transaction_json_data }
        end.to change{ Transaction.count }.by(1)
        expect(Transaction.last.uuid).to eq(authorize_transaction.uuid)
      end

      it 'responds with correct transaction data' do
        post :create, format: :json, params: { transaction: transaction_json_data }
        expect(response.header['Content-Type']).to include 'application/json'
        expect(parsed_json_body[:transaction][:uuid]).to eq(authorize_transaction.uuid)
      end
    end

    context 'when create transaction with correct xml params' do
      it 'responds with 200' do
        post :create, format: :xml, params: { transaction: transaction_xml_data }
        expect(response.status).to eq(200)
      end

      it 'creates transaction record with correct values' do
        expect do
          post :create, format: :xml, params: { transaction: transaction_xml_data }
        end.to change { Transaction.count }.by(1)
        expect(Transaction.last.uuid).to eq(authorize_transaction.uuid)
      end

      it 'responds with correct transaction data' do
        post :create, format: :xml, params: { transaction: transaction_xml_data }
        expect(response.header['Content-Type']).to include 'application/xml'
        expect(response.body).to include(authorize_transaction.uuid)
      end
    end

  end
end

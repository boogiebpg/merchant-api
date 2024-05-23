# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:correct_attrs) do
    %w[
      uuid
      amount
      status
      customer_email
      customer_phone
      type
    ]
  end

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
      .slice(*correct_attrs)
  end

  let(:transaction_with_inactive_merchant_json_data) do
    authorize_transaction_with_inactive_merchant
      .attributes
      .slice(*correct_attrs)
  end

  let(:transaction_with_inactive_merchant_xml_data) do
    authorize_transaction_with_inactive_merchant
      .attributes
      .slice(*correct_attrs)
      .to_xml(root: 'transaction')
  end

  let(:transaction_xml_data) do
    authorize_transaction
      .attributes
      .slice(*correct_attrs)
      .to_xml(root: 'transaction')
  end

  let(:parsed_json_body) do
    JSON.parse(response.body).deep_symbolize_keys
  end

  let(:auth_header) do
    token = AuthenticateUser.call(merchant.email, merchant.password).result
    "Bearer #{token}"
  end

  describe '#create' do
    context 'when create transaction without auth headers' do
      context 'when format is json' do
        it 'responds with a correct error' do
          post :create, format: :json, params: { transaction: transaction_json_data }
          expect(response.status).to eq(401)
          expect(parsed_json_body[:error]).to eq('Not Authorized')
        end
      end

      context 'when format is xml' do
        it 'responds with a correct error' do
          post :create, format: :xml, params: { transaction: transaction_xml_data }
          expect(response.status).to eq(401)
          expect(response.body).to include('Not Authorized')
        end
      end
    end

    context 'when create transaction with incorrect auth headers' do
      before(:each) do
        request.headers['Authorization'] = 'Bearer incorrect'
      end

      context 'when format is json' do
        it 'responds with a correct error' do
          post :create, format: :json, params: { transaction: transaction_json_data }
          expect(response.status).to eq(401)
          expect(parsed_json_body[:error]).to eq('Not Authorized')
        end
      end

      context 'when format is xml' do
        it 'responds with a correct error' do
          post :create, format: :xml, params: { transaction: transaction_xml_data }
          expect(response.status).to eq(401)
          expect(response.body).to include('Not Authorized')
        end
      end
    end

    context 'when create transaction with incorrect json params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 422' do
        post :create, format: :json, params: { transaction: transaction_with_inactive_merchant_json_data }
        expect(response.status).to eq(422)
      end

      it 'includes correct errors' do
        post :create, format: :json, params: { transaction: transaction_with_inactive_merchant_json_data }
        expect(parsed_json_body[:errors][:user]).to include('must exist')
        expect(parsed_json_body[:errors][:user]).to include('Merchant should be active!')
      end
    end

    # context 'when create transaction with incorrect xml params' do
    #   before(:each) do
    #     request.headers['Authorization'] = auth_header
    #   end

    #   it 'responds with 422' do
    #     post :create, format: :xml, params: { transaction: transaction_with_inactive_merchant_xml_data }
    #     expect(response.status).to eq(422)
    #   end

    #   it 'includes correct errors' do
    #     post :create, format: :xml, params: { transaction: transaction_with_inactive_merchant_xml_data }
    #     expect(response.body).to include('must exist')
    #     expect(response.body).to include('Merchant should be active!')
    #   end
    # end

    context 'when create transaction with incorrect parent json params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      let(:transaction_with_incorrect_parent_json) do
        authorize_transaction
          .attributes
          .slice(*correct_attrs)
          .merge(transaction_id: -1)
      end

      it 'responds with 422' do
        post :create, format: :json, params: { transaction: transaction_with_incorrect_parent_json }
        expect(response.status).to eq(422)
      end

      it 'includes correct errors' do
        post :create, format: :json, params: { transaction: transaction_with_incorrect_parent_json }
        expect(parsed_json_body[:errors][:transaction_id]).to include('Parent transaction is incorrect!')
      end
    end

    # context 'when create transaction with incorrect parent xml params' do
    #   before(:each) do
    #     request.headers['Authorization'] = auth_header
    #   end

    #   let(:transaction_with_incorrect_parent_xml) do
    #     authorize_transaction
    #       .attributes
    #       .slice(*correct_attrs)
    #       .merge(transaction_id: -1)
    #       .to_xml(root: 'transaction')
    #   end

    #   it 'responds with 422' do
    #     post :create, format: :xml, params: { transaction: transaction_with_incorrect_parent_xml }
    #     expect(response.status).to eq(422)
    #   end

    #   it 'includes correct errors' do
    #     post :create, format: :xml, params: { transaction: transaction_with_incorrect_parent_xml }
    #     expect(response.body).to include('Parent transaction is incorrect!')
    #   end
    # end

    context 'when create transaction with incorrect parent status' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      let(:parent_authorize_transaction) do
        create(:authorize_transaction, status: Transaction::STATUSES[:error])
      end

      let(:child_charge_transaction) do
        build(:charge_transaction, status: Transaction::STATUSES[:approved])
      end

      let!(:charge_transaction_merchant) do
        create(
          :merchant,
          email: child_charge_transaction.customer_email,
          status: User::Merchant::STATUSES[:active]
        )
      end

      context 'json params' do
        let(:child_charge_transaction_json) do
          child_charge_transaction
            .attributes
            .slice(*correct_attrs)
            .merge(transaction_id: parent_authorize_transaction.id)
        end

        it 'responds with 200' do
          post :create, format: :json, params: { transaction: child_charge_transaction_json }
          expect(response.status).to eq(200)
        end

        it 'sets transaction status to error' do
          post :create, format: :json, params: { transaction: child_charge_transaction_json }
          expect(parsed_json_body[:transaction][:status]).to eq('error')
        end
      end

    #   context 'xml params' do
    #     let(:child_charge_transaction_xml) do
    #       child_charge_transaction
    #         .attributes
    #         .slice(*correct_attrs)
    #         .merge(transaction_id: parent_authorize_transaction.id)
    #         .to_xml(root: 'transaction')
    #     end

    #     it 'responds with 200' do
    #       post :create, format: :xml, params: { transaction: child_charge_transaction_xml }
    #       expect(response.status).to eq(200)
    #     end

    #     it 'sets transaction status to error' do
    #       post :create, format: :xml, params: { transaction: child_charge_transaction_xml }
    #       expect(response.body).to include('<status>error</status>')
    #     end
    #   end
    end

    context 'when create transaction with correct json params' do
      before(:each) do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with 200' do
        post :create, format: :json, params: { transaction: transaction_json_data }
        expect(response.status).to eq(200)
      end

      it 'creates transaction record with correct values' do
        expect do
          post :create,
               format: :json,
               params: { transaction: transaction_json_data }
        end.to change { Transaction.count }.by(1)
        expect(Transaction.last.uuid).to eq(authorize_transaction.uuid)
      end

      it 'responds with correct transaction data' do
        post :create, format: :json, params: { transaction: transaction_json_data }
        expect(response.header['Content-Type']).to include 'application/json'
        expect(parsed_json_body[:transaction][:uuid]).to eq(authorize_transaction.uuid)
      end
    end

    # context 'when create transaction with correct xml params' do
    #   before(:each) do
    #     request.headers['Authorization'] = auth_header
    #   end

    #   it 'responds with 200' do
    #     post :create, format: :xml, params: { transaction: transaction_xml_data }
    #     expect(response.status).to eq(200)
    #   end

    #   it 'creates transaction record with correct values' do
    #     expect do
    #       post :create, format: :xml, params: { transaction: transaction_xml_data }
    #     end.to change { Transaction.count }.by(1)
    #     expect(Transaction.last.uuid).to eq(authorize_transaction.uuid)
    #   end

    #   it 'responds with correct transaction data' do
    #     post :create, format: :xml, params: { transaction: transaction_xml_data }
    #     expect(response.header['Content-Type']).to include 'application/xml'
    #     expect(response.body).to include(authorize_transaction.uuid)
    #   end
    # end
  end
end

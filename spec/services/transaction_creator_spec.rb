# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :service do
  describe '#call' do
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

    context 'when incorrect format provided' do
      it 'raises an error' do
        expect do
          TransactionCreator.call('test', :incorrect)
        end.to raise_error('Not Implemented!')
      end
    end

    context 'when payload is incorrect' do
      context 'when json format provided' do
        let(:incorrect_json_payload) { ActionController::Parameters.new(key: 'value').permit! }
        let(:result) { TransactionCreator.call(incorrect_json_payload, :json) }

        it "doesn't raise an error" do
          expect { result }.not_to raise_error
        end

        it "doesn't create a new record" do
          expect { result }.not_to change { Transaction.count }
        end

        it 'returns a new not persisted Transaction' do
          expect(result).to be_a(Transaction)
          expect(result.id).to be_nil
        end
      end
    end

    context 'when xml format provided' do
      let(:incorrect_xml_payload) { { key: 'value' }.to_xml }
      let(:incorrect_xml_payload_with_root) { { key: 'value' }.to_xml(root: 'transaction') }
      let(:result) { TransactionCreator.call(incorrect_xml_payload_with_root, :xml) }

      it "doesn't raise an error" do
        expect { result }.not_to raise_error
        expect do
          TransactionCreator.call(incorrect_xml_payload, :xml)
        end.not_to raise_error
      end

      it "doesn't create a new record" do
        expect do
          TransactionCreator.call(incorrect_xml_payload, :xml)
        end.not_to change { Transaction.count }
        expect { result }.not_to change { Transaction.count }
      end

      it 'returns a new not persisted Transaction' do
        expect(result).to be_a(Transaction)
        expect(result.id).to be_nil
      end
    end

    context 'when payload is correct' do
      let(:authorize_transaction) do
        build(:authorize_transaction)
      end
      let!(:merchant) do
        create(
          :merchant,
          email: authorize_transaction.customer_email,
          status: User::Merchant::STATUSES[:active]
        )
      end
      context 'when json format provided' do
        let(:transaction_json_data) do
          ActionController::Parameters.new(
            { transaction: authorize_transaction.attributes.slice(*correct_attrs) }
            ).permit!
        end

        context "when new transaction doesn't have a parent" do
          let(:result) { TransactionCreator.call(transaction_json_data, :json) }

          it 'returns persisted Transaction' do
            expect(result).to be_a(Transaction)
            expect(result.id).not_to be_nil
          end

          it 'increases saved transactions count' do
            expect { result }.to change { Transaction.count }.by(1)
          end
        end

        context 'when new transaction has a parent' do
          let(:charge_transaction) do
            build(:charge_transaction)
          end
          let(:transaction_with_incorrect_parent_json) do
            ActionController::Parameters.new(
              {
                transaction: authorize_transaction
                              .attributes
                              .slice(*correct_attrs)
                              .merge(transaction_id: -1)
              }
            ).permit!
          end

          let(:transaction_with_correct_parent_json) do
            ActionController::Parameters.new(
              {
                transaction: charge_transaction
                              .attributes
                              .slice(*correct_attrs)
                              .merge(transaction_id: parent_authorize_transaction.id)
              }
            ).permit!
          end

          let(:transaction_with_incorrect_parents_status_json) do
            ActionController::Parameters.new(
              {
                transaction: charge_transaction
                               .attributes
                               .slice(*correct_attrs)
                               .merge(transaction_id: parent_authorize_transaction_with_wrong_status.id)
              }
            ).permit!
          end

          context 'when parent is incorrect' do
            let(:result) { TransactionCreator.call(transaction_with_incorrect_parent_json, :json) }

            it 'returns not persisted Transaction' do
              expect(result).to be_a(Transaction)
              expect(result.id).to be_nil
            end

            it "doesn't increase saved transactions count" do
              expect { result }.not_to change{ Transaction.count }
            end
          end

          context 'when parent is correct' do
            let!(:parent_authorize_transaction) do
              create(:authorize_transaction)
            end
            before(:each) do
              create(
                :merchant,
                email: charge_transaction.customer_email,
                status: User::Merchant::STATUSES[:active]
              )
            end
            let(:result) { TransactionCreator.call(transaction_with_correct_parent_json, :json) }

            it 'returns persisted Transaction' do
              expect(result).to be_a(Transaction)
              expect(result.id).not_to be_nil
            end

            it 'increases saved transactions count' do
              expect { result }.to change { Transaction.count }.by(1)
            end
          end

          context 'when parent has incorrect status' do
            let!(:parent_authorize_transaction_with_wrong_status) do
              create(:authorize_transaction, status: Transaction::STATUSES[:error])
            end
            before(:each) do
              create(
                :merchant,
                email: charge_transaction.customer_email,
                status: User::Merchant::STATUSES[:active]
              )
            end
            let(:result) { TransactionCreator.call(transaction_with_incorrect_parents_status_json, :json) }

            it 'returns persisted Transaction' do
              expect(result).to be_a(Transaction)
              expect(result.id).not_to be_nil
            end

            it 'increases saved transactions count' do
              expect { result }.to change { Transaction.count }.by(1)
            end

            it 'returns and save Transaction with error status' do
              expect(result.status).to eq('error')
              expect(Transaction.last.status).to eq('error')
            end
          end
        end
      end

      context 'when xml format provided' do
        let(:transaction_xml_data) do
          authorize_transaction
            .attributes
            .slice(*correct_attrs)
            .to_xml(root: 'transaction')
        end

        context "when new transaction doesn't have a parent" do
          let(:result) { TransactionCreator.call(transaction_xml_data, :xml) }

          it 'returns persisted Transaction' do
            expect(result).to be_a(Transaction)
            expect(result.id).not_to be_nil
          end

          it 'increases saved transactions count' do
            expect { result }.to change { Transaction.count }.by(1)
          end
        end

        context 'when new transaction has a parent' do
          let(:charge_transaction) do
            build(:charge_transaction)
          end
          let(:transaction_with_incorrect_parent_xml) do
            authorize_transaction
              .attributes
              .slice(*correct_attrs)
              .merge(transaction_id: -1)
              .to_xml(root: 'transaction')
          end

          let(:transaction_with_correct_parent_xml) do
            charge_transaction
              .attributes
              .slice(*correct_attrs)
              .merge(transaction_id: parent_authorize_transaction.id)
              .to_xml(root: 'transaction')
          end

          let(:transaction_with_incorrect_parents_status_xml) do
            charge_transaction
              .attributes
              .slice(*correct_attrs)
              .merge(transaction_id: parent_authorize_transaction_with_wrong_status.id)
              .to_xml(root: 'transaction')
          end

          context 'when parent is incorrect' do
            let(:result) { TransactionCreator.call(transaction_with_incorrect_parent_xml, :xml) }

            it 'returns not persisted Transaction' do
              expect(result).to be_a(Transaction)
              expect(result.id).to be_nil
            end

            it "doesn't increase saved transactions count" do
              expect { result }.not_to change { Transaction.count }
            end
          end

          context 'when parent is correct' do
            let!(:parent_authorize_transaction) do
              create(:authorize_transaction)
            end
            before(:each) do
              create(
                :merchant,
                email: charge_transaction.customer_email,
                status: User::Merchant::STATUSES[:active]
              )
            end
            let(:result) { TransactionCreator.call(transaction_with_correct_parent_xml, :xml) }

            it 'returns persisted Transaction' do
              expect(result).to be_a(Transaction)
              expect(result.id).not_to be_nil
            end

            it 'increases saved transactions count' do
              expect { result }.to change { Transaction.count }.by(1)
            end
          end

          context 'when parent has incorrect status' do
            let!(:parent_authorize_transaction_with_wrong_status) do
              create(:authorize_transaction, status: Transaction::STATUSES[:error])
            end
            before(:each) do
              create(
                :merchant,
                email: charge_transaction.customer_email,
                status: User::Merchant::STATUSES[:active]
              )
            end
            let(:result) { TransactionCreator.call(transaction_with_incorrect_parents_status_xml, :xml) }

            it 'returns persisted Transaction' do
              expect(result).to be_a(Transaction)
              expect(result.id).not_to be_nil
            end

            it 'increases saved transactions count' do
              expect { result }.to change { Transaction.count }.by(1)
            end

            it 'returns and save Transaction with error status' do
              expect(result.status).to eq('error')
              expect(Transaction.last.status).to eq('error')
            end
          end
        end
      end
    end
  end
end

class TransactionsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        new_transaction = TransactionCreator.call(params[:transaction], :json)
        render json: { transaction: new_transaction }
      end
      format.xml do
        new_transaction = TransactionCreator.call(params[:transaction], :xml)
        render xml: new_transaction.attributes.to_xml(root: "transaction")
      end
    end
  end
end

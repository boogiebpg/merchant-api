# frozen_string_literal: true

module TransactionsHelper
  def render_response(transaction, format)
    case format
    when :json
      render_json_response(transaction)
    when :xml
      render_xml_response(transaction)
    end
  end

  def render_json_response(transaction)
    if transaction.persisted?
      render json: { transaction: }
    else
      render json: { errors: transaction.errors.messages }, status: 422
    end
  end

  def render_xml_response(transaction)
    if transaction.persisted?
      render xml: transaction.attributes.to_xml(root: 'transaction')
    else
      render xml: transaction.errors.messages.to_xml(root: 'transaction'), status: 422
    end
  end
end

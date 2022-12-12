# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    return if @current_user

    respond_to do |format|
      format.json do
        render json: { error: 'Not Authorized' }, status: 401
      end
      format.xml do
        render xml: '<error>Not Authorized</error>', status: 401
      end
    end
  end
end

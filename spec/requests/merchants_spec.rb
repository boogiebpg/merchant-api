# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Merchants', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/merchants'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    let(:merchant) do
      create(
        :merchant
      )
    end
    it 'returns http success' do
      get "/merchants/#{merchant.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/merchants/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    let(:merchant) do
      create(
        :merchant
      )
    end
    it 'returns http success' do
      get "/merchants/#{merchant.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end
end

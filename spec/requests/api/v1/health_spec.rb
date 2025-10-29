require 'rails_helper'

RSpec.describe 'Api::V1::Health', type: :request do
  describe 'GET /api/v1/health' do
    it 'returns a successful response' do
      get '/api/v1/health'
      
      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('ok')
      expect(json_response['message']).to eq('API is running')
    end
  end
end

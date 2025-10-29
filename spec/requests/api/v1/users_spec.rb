require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:user) { create(:user, email: 'test@example.com') }

  describe 'GET /api/v1/users/me' do
    context 'when user is authenticated' do
      it 'returns the current user profile' do
        get '/api/v1/users/me', headers: auth_headers(user)
        
        expect(response).to have_http_status(:ok)
        expect(json_response['user']['email']).to eq('test@example.com')
        expect(json_response['user']['role']).to eq('member')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/users/me'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

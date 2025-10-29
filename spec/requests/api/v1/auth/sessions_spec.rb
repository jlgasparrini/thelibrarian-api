require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe 'POST /api/v1/auth/sign_in' do
    context 'with valid credentials' do
      let(:valid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'password123'
          }
        }
      end

      it 'returns a success message' do
        post '/api/v1/auth/sign_in', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Logged in successfully.')
        expect(json_response['user']['email']).to eq('test@example.com')
      end

      it 'returns a JWT token in the Authorization header' do
        post '/api/v1/auth/sign_in', params: valid_params

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'wrongpassword'
          }
        }
      end

      it 'returns an unauthorized status' do
        post '/api/v1/auth/sign_in', params: invalid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/auth/sign_out' do
    context 'when user is logged in' do
      it 'logs out the user successfully' do
        # First, sign in to get a token
        post '/api/v1/auth/sign_in', params: {
          user: {
            email: 'test@example.com',
            password: 'password123'
          }
        }

        token = response.headers['Authorization']

        # Then, sign out with the token
        delete '/api/v1/auth/sign_out', headers: { 'Authorization' => token }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Logged out successfully.')
      end
    end
  end
end

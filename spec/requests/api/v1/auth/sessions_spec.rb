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

      it 'does not include an Authorization header' do
        post '/api/v1/auth/sign_in', params: invalid_params

        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'with non-existent user' do
      let(:nonexistent_params) do
        {
          user: {
            email: 'does-not-exist@example.com',
            password: 'irrelevant'
          }
        }
      end

      it 'returns 401 and no Authorization header' do
        post '/api/v1/auth/sign_in', params: nonexistent_params

        expect(response).to have_http_status(:unauthorized)
        expect(response.headers['Authorization']).to be_nil
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with invalid credentials but an Authorization header present' do
      it 'still returns 401 and ignores the provided token' do
        existing_token_headers = auth_headers(user)
        post '/api/v1/auth/sign_in', params: { user: { email: 'test@example.com', password: 'wrongpassword' } }, headers: existing_token_headers

        expect(response).to have_http_status(:unauthorized)
        expect(response.headers['Authorization']).to be_nil
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

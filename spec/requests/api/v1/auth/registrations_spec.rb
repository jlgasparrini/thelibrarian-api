require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  describe 'POST /api/v1/auth/sign_up' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post '/api/v1/auth/sign_up', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns a success message' do
        post '/api/v1/auth/sign_up', params: valid_params

        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq('Signed up successfully.')
        expect(json_response['user']['email']).to eq('newuser@example.com')
        expect(json_response['user']['role']).to eq('member')
      end

      it 'returns a JWT token in the Authorization header' do
        post '/api/v1/auth/sign_up', params: valid_params

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            email: 'invalid',
            password: 'short'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post '/api/v1/auth/sign_up', params: invalid_params
        }.not_to change(User, :count)
      end

      it 'returns error messages' do
        post '/api/v1/auth/sign_up', params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['message']).to eq('User could not be created.')
        expect(json_response['errors']).to be_present
      end
    end
  end
end

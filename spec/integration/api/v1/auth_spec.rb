require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/sign_up' do
    post('Register a new user') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, format: :password },
              password_confirmation: { type: :string, format: :password },
              role: { type: :string, enum: [ 'member', 'librarian' ], default: 'member' }
            },
            required: [ 'email', 'password', 'password_confirmation' ]
          }
        }
      }

      response(201, 'user created') do
        header 'Authorization', schema: { type: :string }, description: 'JWT token'
        
        schema type: :object,
          properties: {
            message: { type: :string },
            user: { '$ref' => '#/components/schemas/User' }
          }
        
        let(:user) do
          {
            user: {
              email: 'newuser@example.com',
              password: 'password123',
              password_confirmation: 'password123',
              role: 'member'
            }
          }
        end
        
        run_test! do |response|
          expect(response.headers['Authorization']).to be_present
        end
      end

      response(422, 'invalid request') do
        schema type: :object,
          properties: {
            message: { type: :string },
            errors: {
              type: :array,
              items: { type: :string }
            }
          }
        
        let(:user) { { user: { email: 'invalid', password: 'short' } } }
        
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_in' do
    post('Sign in') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, format: :password }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response(200, 'signed in successfully') do
        header 'Authorization', schema: { type: :string }, description: 'JWT token'
        
        schema type: :object,
          properties: {
            message: { type: :string }
          }
        
        let!(:existing_user) { create(:user, :member, email: 'test@example.com', password: 'password123') }
        let(:user) { { user: { email: 'test@example.com', password: 'password123' } } }
        
        run_test! do |response|
          expect(response.headers['Authorization']).to be_present
        end
      end

      response(401, 'invalid credentials') do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:user) { { user: { email: 'wrong@example.com', password: 'wrongpassword' } } }
        
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_out' do
    delete('Sign out') do
      tags 'Authentication'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'signed out successfully') do
        schema type: :object,
          properties: {
            message: { type: :string }
          }
        
        let(:user) { create(:user, :member) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        
        run_test!
      end

      response(401, 'not authenticated') do
        schema type: :object,
          properties: {
            message: { type: :string }
          }
        
        let(:Authorization) { nil }
        
        run_test!
      end
    end
  end
end

def generate_jwt_token(user)
  Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
end

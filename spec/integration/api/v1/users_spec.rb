require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users/me' do
    get('Get current user profile') do
      tags 'Users'
      produces 'application/json'
      security [ Bearer: [] ]
      description 'Returns the profile information of the currently authenticated user'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                email: { type: :string, format: :email },
                role: { type: :string, enum: [ 'librarian', 'member' ] },
                created_at: { type: :string, format: :datetime }
              },
              required: [ 'id', 'email', 'role' ]
            }
          },
          required: [ 'user' ]

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('user')
          expect(data['user']).to have_key('id')
          expect(data['user']).to have_key('email')
          expect(data['user']).to have_key('role')
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end

def generate_jwt_token(user)
  Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
end

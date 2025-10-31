require 'swagger_helper'

RSpec.describe 'api/v1/dashboard', type: :request do
  path '/api/v1/dashboard' do
    get('Get dashboard statistics') do
      tags 'Dashboard'
      produces 'application/json'
      security [ Bearer: [] ]
      description 'Returns role-specific dashboard statistics. Librarians see library-wide stats, members see their personal stats.'

      response(200, 'successful - librarian dashboard') do
        schema type: :object,
          properties: {
            dashboard: {
              type: :object,
              properties: {
                total_books: { type: :integer },
                total_available_books: { type: :integer },
                total_borrowed_books: { type: :integer },
                total_members: { type: :integer },
                overdue_books: { type: :integer },
                books_due_today: { type: :integer },
                members_with_overdue_books: { type: :integer },
                recent_borrowings: { type: :array },
                popular_books: { type: :array },
                overdue_borrowings: { type: :array }
              }
            }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :librarian))}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('dashboard')
          expect(data['dashboard']).to have_key('total_books')
        end
      end

      response(200, 'successful - member dashboard') do
        schema type: :object,
          properties: {
            dashboard: {
              type: :object,
              properties: {
                active_borrowings_count: { type: :integer },
                overdue_borrowings_count: { type: :integer },
                books_due_soon: { type: :integer },
                borrowed_books: { type: :array },
                borrowing_history: { type: :array }
              }
            }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('dashboard')
          expect(data['dashboard']).to have_key('active_borrowings_count')
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

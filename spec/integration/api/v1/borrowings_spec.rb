require 'swagger_helper'

RSpec.describe 'api/v1/borrowings', type: :request do
  path '/api/v1/borrowings' do
    get('List all borrowings') do
      tags 'Borrowings'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status (borrowed, returned)'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            borrowings: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Borrowing' }
            },
            pagination: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                per_page: { type: :integer },
                total_count: { type: :integer },
                total_pages: { type: :integer }
              }
            }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('borrowings')
          expect(data).to have_key('pagination')
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { nil }

        run_test!
      end
    end

    post('Borrow a book') do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :borrowing, in: :body, schema: {
        type: :object,
        properties: {
          borrowing: {
            type: :object,
            properties: {
              book_id: { type: :integer }
            },
            required: [ 'book_id' ]
          }
        }
      }

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/Borrowing'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:book) { create(:book, available_copies: 5) }
        let(:borrowing) { { borrowing: { book_id: book.id } } }

        run_test!
      end

      response(422, 'book not available') do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:book) { create(:book, available_copies: 0) }
        let(:borrowing) { { borrowing: { book_id: book.id } } }

        run_test!
      end
    end
  end

  path '/api/v1/borrowings/overdue' do
    get('List overdue borrowings') do
      tags 'Borrowings'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            borrowings: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Borrowing' }
            },
            pagination: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                per_page: { type: :integer },
                total_count: { type: :integer },
                total_pages: { type: :integer }
              }
            }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :librarian))}" }

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path '/api/v1/borrowings/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Borrowing ID'

    get('Show a borrowing') do
      tags 'Borrowings'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Borrowing'

        let(:user) { create(:user, :member) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:id) { create(:borrowing, user: user).id }

        run_test!
      end

      response(404, 'borrowing not found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:id) { 'invalid' }

        run_test!
      end
    end

    patch('Return a book') do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :action_type, in: :query, type: :string, required: true, description: 'Action to perform (return)'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Borrowing'

        let(:librarian) { create(:user, :librarian) }
        let(:Authorization) { "Bearer #{generate_jwt_token(librarian)}" }
        let(:id) { create(:borrowing, returned_at: nil).id }
        let(:action_type) { 'return' }

        run_test!
      end

      response(403, 'forbidden - only librarians can update borrowings') do
        schema '$ref' => '#/components/schemas/Error'

        let(:member) { create(:user, :member) }
        let(:Authorization) { "Bearer #{generate_jwt_token(member)}" }
        let(:id) { create(:borrowing, user: member, returned_at: nil).id }
        let(:action_type) { 'return' }

        run_test!
      end
    end
  end
end

def generate_jwt_token(user)
  Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
end

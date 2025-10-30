require 'swagger_helper'

RSpec.describe 'api/v1/books', type: :request do
  path '/api/v1/books' do
    get('List all books') do
      tags 'Books'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            books: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Book' }
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
          expect(data).to have_key('books')
          expect(data).to have_key('pagination')
        end
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { nil }

        run_test!
      end
    end

    post('Create a book') do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            type: :object,
            properties: {
              title: { type: :string },
              author: { type: :string },
              genre: { type: :string },
              isbn: { type: :string },
              total_copies: { type: :integer },
              available_copies: { type: :integer }
            },
            required: [ 'title', 'author', 'genre', 'isbn', 'total_copies', 'available_copies' ]
          }
        }
      }

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/Book'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :librarian))}" }
        let(:book) { { book: attributes_for(:book) } }

        run_test!
      end

      response(403, 'forbidden - only librarians can create books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:book) { { book: attributes_for(:book) } }

        run_test!
      end

      response(422, 'invalid request') do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :librarian))}" }
        let(:book) { { book: { title: '' } } }

        run_test!
      end
    end
  end

  path '/api/v1/books/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Book ID'

    get('Show a book') do
      tags 'Books'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Book'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:id) { create(:book).id }

        run_test!
      end

      response(404, 'book not found') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:id) { 'invalid' }

        run_test!
      end
    end

    patch('Update a book') do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            type: :object,
            properties: {
              title: { type: :string },
              author: { type: :string },
              genre: { type: :string },
              isbn: { type: :string },
              total_copies: { type: :integer },
              available_copies: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Book'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :librarian))}" }
        let(:id) { create(:book).id }
        let(:book) { { book: { title: 'Updated Title' } } }

        run_test!
      end

      response(403, 'forbidden - only librarians can update books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:id) { create(:book).id }
        let(:book) { { book: { title: 'Updated Title' } } }

        run_test!
      end
    end

    delete('Delete a book') do
      tags 'Books'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :librarian))}" }
        let(:id) { create(:book).id }

        run_test!
      end

      response(403, 'forbidden - only librarians can delete books') do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { "Bearer #{generate_jwt_token(create(:user, :member))}" }
        let(:id) { create(:book).id }

        run_test!
      end
    end
  end
end

def generate_jwt_token(user)
  Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
end

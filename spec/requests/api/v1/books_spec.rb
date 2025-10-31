require 'rails_helper'

RSpec.describe 'Api::V1::Books', type: :request do
  let(:member) { create(:user, :member) }
  let(:librarian) { create(:user, :librarian) }
  let!(:book1) { create(:book, title: 'Ruby Programming', author: 'John Doe', genre: 'Programming') }
  let!(:book2) { create(:book, title: 'Python Basics', author: 'Jane Smith', genre: 'Programming') }
  let!(:book3) { create(:book, title: 'Fiction Novel', author: 'Alice Brown', genre: 'Fiction', available_copies: 0) }

  describe 'GET /api/v1/books' do
    context 'when user is authenticated' do
      it 'returns all books for members' do
        get '/api/v1/books', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['books'].count).to eq(3)
      end

      it 'returns all books for librarians' do
        get '/api/v1/books', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['books'].count).to eq(3)
      end

      it 'filters books by search query' do
        get '/api/v1/books', params: { query: 'Ruby' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['books'].count).to eq(1)
        expect(json_response['books'].first['title']).to eq('Ruby Programming')
      end

      it 'filters books by genre' do
        get '/api/v1/books', params: { genre: 'Programming' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['books'].count).to eq(2)
      end

      it 'filters available books only' do
        get '/api/v1/books', params: { available: 'true' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['books'].count).to eq(2)
      end

      it 'sorts books by title' do
        get '/api/v1/books', params: { sort: 'title' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['books'].first['title']).to eq('Fiction Novel')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/books'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/books/:id' do
    context 'when user is authenticated' do
      it 'returns the book for members' do
        get "/api/v1/books/#{book1.id}", headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['book']['title']).to eq('Ruby Programming')
      end

      it 'returns the book for librarians' do
        get "/api/v1/books/#{book1.id}", headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['book']['title']).to eq('Ruby Programming')
      end
    end

    context 'when book does not exist' do
      it 'returns not found' do
        get '/api/v1/books/99999', headers: auth_headers(member)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/books' do
    let(:valid_params) do
      {
        book: {
          title: 'New Book',
          author: 'New Author',
          genre: 'Science',
          isbn: '978-1234567890',
          total_copies: 10,
          available_copies: 10
        }
      }
    end

    let(:invalid_params) do
      {
        book: {
          title: '',
          author: 'New Author'
        }
      }
    end

    context 'when user is a librarian' do
      it 'creates a new book with valid params' do
        expect {
          post '/api/v1/books', params: valid_params, headers: auth_headers(librarian)
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['book']['title']).to eq('New Book')
        expect(json_response['message']).to eq('Book created successfully')
      end

      it 'returns errors with invalid params' do
        post '/api/v1/books', params: invalid_params, headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to be_present
      end
    end

    context 'when user is a member' do
      it 'returns forbidden' do
        post '/api/v1/books', params: valid_params, headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT /api/v1/books/:id' do
    let(:update_params) do
      {
        book: {
          title: 'Updated Title'
        }
      }
    end

    context 'when user is a librarian' do
      it 'updates the book' do
        put "/api/v1/books/#{book1.id}", params: update_params, headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['book']['title']).to eq('Updated Title')
        expect(json_response['message']).to eq('Book updated successfully')
      end

      it 'allows lowering total_copies when there are still available copies and keeps consistency with active borrowings' do
        # Setup: total_copies = 6, available_copies = 6
        book = create(:book, total_copies: 6, available_copies: 6)
        # One active borrowing reduces available_copies to 5
        create(:borrowing, book: book, user: member)
        book.reload
        expect(book.available_copies).to eq(5)

        # Lower total_copies to 4 (since only 1 is borrowed, this should be allowed)
        put "/api/v1/books/#{book.id}",
            params: { book: { total_copies: 4 } },
            headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        book.reload
        expect(book.total_copies).to eq(4)
        # available_copies should equal new total minus active borrowings (4 - 1 = 3)
        expect(book.available_copies).to eq(3)
      end

      it 'rejects lowering total_copies below active borrowings' do
        # Setup: total_copies = 2, available_copies = 2
        book = create(:book, total_copies: 2, available_copies: 2)
        # Two active borrowings make available_copies = 0
        create(:borrowing, book: book, user: member)
        create(:borrowing, book: book, user: create(:user, :member))
        book.reload
        expect(book.available_copies).to eq(0)

        # Attempt to lower total_copies to 1 (less than active borrowings 2) should fail
        put "/api/v1/books/#{book.id}",
            params: { book: { total_copies: 1 } },
            headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors'].join).to match(/cannot be less than active borrowings/)
      end

      it 'recomputes available_copies when increasing total_copies (total - active borrowings)' do
        # Setup: total_copies = 3, available_copies = 3
        book = create(:book, total_copies: 3, available_copies: 3)
        # One active borrowing -> available becomes 2
        create(:borrowing, book: book, user: member)
        book.reload
        expect(book.available_copies).to eq(2)

        # Increase total to 5 => available should become 5 - 1 = 4
        put "/api/v1/books/#{book.id}",
            params: { book: { total_copies: 5 } },
            headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        book.reload
        expect(book.total_copies).to eq(5)
        expect(book.available_copies).to eq(4)
      end

      it 'rejects lowering total_copies when all copies are borrowed' do
        # Setup: total_copies = 6, available_copies = 6
        book = create(:book, total_copies: 6, available_copies: 6)
        # Borrow all copies by different members -> available becomes 0
        6.times do
          create(:borrowing, book: book, user: create(:user, :member))
        end
        book.reload
        expect(book.available_copies).to eq(0)

        # Attempt to lower total_copies to 5 (less than active borrowings 6) should fail
        put "/api/v1/books/#{book.id}",
            params: { book: { total_copies: 5 } },
            headers: auth_headers(librarian)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors'].join).to match(/cannot be less than active borrowings/)
      end
    end

    context 'when user is a member' do
      it 'returns forbidden' do
        put "/api/v1/books/#{book1.id}", params: update_params, headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/books/:id' do
    context 'when user is a librarian' do
      it 'deletes the book' do
        expect {
          delete "/api/v1/books/#{book1.id}", headers: auth_headers(librarian)
        }.to change(Book, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Book deleted successfully')
      end
    end

    context 'when user is a member' do
      it 'returns forbidden' do
        delete "/api/v1/books/#{book1.id}", headers: auth_headers(member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

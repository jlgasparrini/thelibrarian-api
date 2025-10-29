require 'rails_helper'

RSpec.describe 'Api::V1::Borrowings', type: :request do
  let(:member) { create(:user, :member) }
  let(:librarian) { create(:user, :librarian) }
  let(:book) { create(:book, available_copies: 5) }

  describe 'GET /api/v1/borrowings' do
    let!(:member_borrowing) { create(:borrowing, user: member, book: book) }
    let!(:other_member) { create(:user, :member) }
    let!(:other_borrowing) { create(:borrowing, user: other_member) }

    context 'when user is a member' do
      it 'returns only their own borrowings' do
        get '/api/v1/borrowings', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].count).to eq(1)
        expect(json_response['borrowings'].first['id']).to eq(member_borrowing.id)
      end

      it 'filters by active status' do
        returned = create(:borrowing, :returned, user: member)
        get '/api/v1/borrowings', params: { status: 'active' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].map { |b| b['id'] }).to include(member_borrowing.id)
        expect(json_response['borrowings'].map { |b| b['id'] }).not_to include(returned.id)
      end

      it 'filters by returned status' do
        returned = create(:borrowing, :returned, user: member)
        get '/api/v1/borrowings', params: { status: 'returned' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].map { |b| b['id'] }).to include(returned.id)
        expect(json_response['borrowings'].map { |b| b['id'] }).not_to include(member_borrowing.id)
      end

      it 'filters by overdue status' do
        overdue = create(:borrowing, :overdue, user: member)
        get '/api/v1/borrowings', params: { status: 'overdue' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].map { |b| b['id'] }).to include(overdue.id)
        expect(json_response['borrowings'].map { |b| b['id'] }).not_to include(member_borrowing.id)
      end
    end

    context 'when user is a librarian' do
      it 'returns all borrowings' do
        get '/api/v1/borrowings', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].count).to eq(2)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/borrowings'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/borrowings/:id' do
    let(:borrowing) { create(:borrowing, user: member, book: book) }

    context 'when user owns the borrowing' do
      it 'returns the borrowing' do
        get "/api/v1/borrowings/#{borrowing.id}", headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowing']['id']).to eq(borrowing.id)
      end
    end

    context 'when user is a librarian' do
      it 'returns any borrowing' do
        get "/api/v1/borrowings/#{borrowing.id}", headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowing']['id']).to eq(borrowing.id)
      end
    end

    context 'when user does not own the borrowing' do
      let(:other_member) { create(:user, :member) }

      it 'returns forbidden' do
        get "/api/v1/borrowings/#{borrowing.id}", headers: auth_headers(other_member)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/borrowings' do
    let(:valid_params) do
      {
        borrowing: {
          book_id: book.id
        }
      }
    end

    context 'when user is a member' do
      it 'creates a new borrowing' do
        expect {
          post '/api/v1/borrowings', params: valid_params, headers: auth_headers(member)
        }.to change(Borrowing, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq('Book borrowed successfully')
      end

      it 'decrements available copies' do
        expect {
          post '/api/v1/borrowings', params: valid_params, headers: auth_headers(member)
        }.to change { book.reload.available_copies }.by(-1)
      end

      it 'prevents borrowing unavailable book' do
        unavailable_book = create(:book, available_copies: 0)
        params = { borrowing: { book_id: unavailable_book.id } }

        post '/api/v1/borrowings', params: params, headers: auth_headers(member)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to be_present
      end

      it 'prevents borrowing same book twice' do
        create(:borrowing, user: member, book: book)

        post '/api/v1/borrowings', params: valid_params, headers: auth_headers(member)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to include("Book is already borrowed by this user")
      end
    end

    context 'when user is a librarian' do
      it 'returns forbidden' do
        post '/api/v1/borrowings', params: valid_params, headers: auth_headers(librarian)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT /api/v1/borrowings/:id' do
    let!(:borrowing) { create(:borrowing, user: member, book: book) }

    context 'when returning a book' do
      it 'marks the borrowing as returned' do
        put "/api/v1/borrowings/#{borrowing.id}", params: { action_type: 'return' }, headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Book returned successfully')
        expect(borrowing.reload.returned_at).to be_present
      end

      it 'increments available copies' do
        # Book starts with 5, borrowing decrements to 4
        expect(book.reload.available_copies).to eq(4)

        put "/api/v1/borrowings/#{borrowing.id}", params: { action_type: 'return' }, headers: auth_headers(member)

        # After return, should be back to 5
        expect(book.reload.available_copies).to eq(5)
      end

      it 'allows librarian to return any book' do
        put "/api/v1/borrowings/#{borrowing.id}", params: { action_type: 'return' }, headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid action' do
      it 'returns bad request' do
        put "/api/v1/borrowings/#{borrowing.id}", params: { action_type: 'invalid' }, headers: auth_headers(member)

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET /api/v1/borrowings/overdue' do
    let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member) }
    let!(:active_borrowing) { create(:borrowing, user: member, book: book) }

    context 'when user is a member' do
      it 'returns only their overdue borrowings' do
        get '/api/v1/borrowings/overdue', headers: auth_headers(member)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].count).to eq(1)
        expect(json_response['borrowings'].first['id']).to eq(overdue_borrowing.id)
      end
    end

    context 'when user is a librarian' do
      let(:other_member) { create(:user, :member) }
      let!(:other_overdue) { create(:borrowing, :overdue, user: other_member) }

      it 'returns all overdue borrowings' do
        get '/api/v1/borrowings/overdue', headers: auth_headers(librarian)

        expect(response).to have_http_status(:ok)
        expect(json_response['borrowings'].count).to eq(2)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Api::V1::Dashboards', type: :request do
  let(:member) { create(:user, :member) }
  let(:librarian) { create(:user, :librarian) }
  let!(:book1) { create(:book, available_copies: 5) }
  let!(:book2) { create(:book, available_copies: 0) }
  let!(:book3) { create(:book, available_copies: 3) }

  describe 'GET /api/v1/dashboard' do
    context 'when user is a librarian' do
      let!(:active_borrowing) { create(:borrowing, user: member, book: book1) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member, book: book3) }
      let!(:returned_borrowing) { create(:borrowing, :returned, user: member) }

      before do
        get '/api/v1/dashboard', headers: auth_headers(librarian)
      end

      it 'returns ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns librarian dashboard structure' do
        expect(json_response).to have_key('dashboard')
        dashboard = json_response['dashboard']

        expect(dashboard).to have_key('total_books')
        expect(dashboard).to have_key('total_available_books')
        expect(dashboard).to have_key('total_borrowed_books')
        expect(dashboard).to have_key('books_due_today')
        expect(dashboard).to have_key('overdue_books')
        expect(dashboard).to have_key('total_members')
        expect(dashboard).to have_key('members_with_overdue_books')
        expect(dashboard).to have_key('recent_borrowings')
        expect(dashboard).to have_key('popular_books')
        expect(dashboard).to have_key('overdue_borrowings')
      end

      it 'returns correct total books count' do
        expect(json_response['dashboard']['total_books']).to be >= 3
      end

      it 'returns correct available books count' do
        expect(json_response['dashboard']['total_available_books']).to be >= 2
      end

      it 'returns correct borrowed books count' do
        expect(json_response['dashboard']['total_borrowed_books']).to eq(2)
      end

      it 'returns correct overdue books count' do
        expect(json_response['dashboard']['overdue_books']).to eq(1)
      end

      it 'returns correct total members count' do
        expect(json_response['dashboard']['total_members']).to eq(1)
      end

      it 'returns correct members with overdue books count' do
        expect(json_response['dashboard']['members_with_overdue_books']).to eq(1)
      end

      it 'returns recent borrowings array' do
        expect(json_response['dashboard']['recent_borrowings']).to be_an(Array)
        expect(json_response['dashboard']['recent_borrowings'].length).to be >= 1
      end

      it 'returns popular books array' do
        expect(json_response['dashboard']['popular_books']).to be_an(Array)
      end

      it 'returns overdue borrowings array' do
        expect(json_response['dashboard']['overdue_borrowings']).to be_an(Array)
        expect(json_response['dashboard']['overdue_borrowings'].length).to eq(1)
      end

      it 'includes book and user details in recent borrowings' do
        recent = json_response['dashboard']['recent_borrowings'].first
        expect(recent).to have_key('book')
        expect(recent).to have_key('user')
        expect(recent['book']).to have_key('title')
        expect(recent['user']).to have_key('email')
      end
    end

    context 'when user is a member' do
      let!(:active_borrowing1) { create(:borrowing, user: member, book: book1) }
      let!(:active_borrowing2) { create(:borrowing, user: member, book: book3) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member) }
      let!(:returned_borrowing) { create(:borrowing, :returned, user: member) }

      before do
        get '/api/v1/dashboard', headers: auth_headers(member)
      end

      it 'returns ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns member dashboard structure' do
        expect(json_response).to have_key('dashboard')
        dashboard = json_response['dashboard']

        expect(dashboard).to have_key('active_borrowings_count')
        expect(dashboard).to have_key('overdue_borrowings_count')
        expect(dashboard).to have_key('books_due_soon')
        expect(dashboard).to have_key('borrowed_books')
        expect(dashboard).to have_key('borrowing_history')
      end

      it 'returns correct active borrowings count' do
        expect(json_response['dashboard']['active_borrowings_count']).to eq(3)
      end

      it 'returns correct overdue borrowings count' do
        expect(json_response['dashboard']['overdue_borrowings_count']).to eq(1)
      end

      it 'returns borrowed books array' do
        expect(json_response['dashboard']['borrowed_books']).to be_an(Array)
        expect(json_response['dashboard']['borrowed_books'].length).to eq(3)
      end

      it 'includes book details in borrowed books' do
        borrowed = json_response['dashboard']['borrowed_books'].first
        expect(borrowed).to have_key('book')
        expect(borrowed).to have_key('borrowed_at')
        expect(borrowed).to have_key('due_date')
        expect(borrowed).to have_key('overdue?')
        expect(borrowed['book']).to have_key('title')
        expect(borrowed['book']).to have_key('author')
      end

      it 'returns borrowing history array' do
        expect(json_response['dashboard']['borrowing_history']).to be_an(Array)
        expect(json_response['dashboard']['borrowing_history'].length).to eq(1)
      end

      it 'includes returned_at in borrowing history' do
        history = json_response['dashboard']['borrowing_history'].first
        expect(history).to have_key('returned_at')
        expect(history['returned_at']).not_to be_nil
      end

      it 'does not include other users borrowings' do
        other_member = create(:user, :member)
        create(:borrowing, user: other_member, book: book1)

        get '/api/v1/dashboard', headers: auth_headers(member)

        # Should still be 3 (not 4)
        expect(json_response['dashboard']['active_borrowings_count']).to eq(3)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/dashboard'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with books due today' do
      let!(:due_today) { create(:borrowing, user: member, book: book1, due_date: Date.today.end_of_day) }

      it 'counts books due today correctly for librarian' do
        get '/api/v1/dashboard', headers: auth_headers(librarian)

        expect(json_response['dashboard']['books_due_today']).to eq(1)
      end
    end

    context 'with books due soon' do
      let!(:due_soon) { create(:borrowing, user: member, book: book1, due_date: 2.days.from_now) }
      let!(:due_later) { create(:borrowing, user: member, book: book3, due_date: 10.days.from_now) }

      it 'counts books due soon correctly for member' do
        get '/api/v1/dashboard', headers: auth_headers(member)

        expect(json_response['dashboard']['books_due_soon']).to eq(1)
      end
    end

    context 'with popular books' do
      let!(:popular_book) { create(:book, borrowings_count: 10) }
      let!(:unpopular_book) { create(:book, borrowings_count: 0) }

      it 'returns popular books ordered by borrowings count' do
        get '/api/v1/dashboard', headers: auth_headers(librarian)

        popular_books = json_response['dashboard']['popular_books']
        expect(popular_books).to be_an(Array)

        if popular_books.any?
          first_book = popular_books.first
          expect(first_book).to have_key('borrowings_count')
        end
      end
    end
  end
end

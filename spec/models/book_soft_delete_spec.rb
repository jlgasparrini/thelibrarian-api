require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'soft delete' do
    let(:book) { create(:book, title: 'Test Book') }

    describe '#destroy' do
      it 'soft deletes the book instead of removing it' do
        book # create the book first
        expect { book.destroy }.not_to change(Book.with_deleted, :count)
      end

      it 'sets deleted_at timestamp' do
        book.destroy
        expect(book.deleted_at).not_to be_nil
      end

      it 'excludes soft deleted books from default scope' do
        book.destroy
        expect(Book.all).not_to include(book)
      end

      it 'can be found with with_deleted scope' do
        book.destroy
        expect(Book.with_deleted).to include(book)
      end
    end

    describe '#really_destroy!' do
      it 'permanently deletes the book' do
        book_id = book.id
        book.really_destroy!
        expect(Book.with_deleted.find_by(id: book_id)).to be_nil
      end
    end

    describe '#restore' do
      it 'restores a soft deleted book' do
        book.destroy
        book.restore
        expect(Book.all).to include(book)
        expect(book.deleted_at).to be_nil
      end
    end

    describe '.only_deleted' do
      it 'returns only soft deleted books' do
        deleted_book = create(:book, title: 'Deleted Book')
        active_book = create(:book, title: 'Active Book')

        deleted_book.destroy

        expect(Book.only_deleted).to include(deleted_book)
        expect(Book.only_deleted).not_to include(active_book)
      end
    end

    describe 'with associations' do
      let!(:borrowing) { create(:borrowing, book: book) }

      it 'soft deletes associated borrowings when book is destroyed' do
        book.destroy
        expect(Borrowing.with_deleted.find(borrowing.id).deleted_at).not_to be_nil
      end
    end

    describe 'uniqueness validation with soft delete' do
      it 'allows creating a book with same ISBN after soft delete' do
        isbn = book.isbn
        book.destroy

        new_book = build(:book, isbn: isbn)
        expect(new_book).to be_valid
      end

      it 'prevents creating a book with same ISBN as active book' do
        isbn = book.isbn
        new_book = build(:book, isbn: isbn)
        expect(new_book).not_to be_valid
      end
    end
  end
end

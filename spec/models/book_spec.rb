require 'rails_helper'

RSpec.describe Book, type: :model do
  subject { build(:book) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:isbn) }
    it { should validate_uniqueness_of(:isbn).case_insensitive }
    it { should validate_presence_of(:total_copies) }
    it { should validate_numericality_of(:total_copies).only_integer.is_greater_than_or_equal_to(0) }

    it 'allows available_copies equal to total_copies' do
      book = build(:book, total_copies: 5, available_copies: 5)
      expect(book).to be_valid
    end
  end

  describe 'scopes' do
    let!(:available_book) { create(:book, available_copies: 3) }
    let!(:unavailable_book) { create(:book, :unavailable) }
    let!(:fiction_book) { create(:book, genre: 'Fiction') }
    let!(:science_book) { create(:book, genre: 'Science') }

    describe '.available' do
      it 'returns only books with available copies' do
        expect(Book.available).to include(available_book)
        expect(Book.available).not_to include(unavailable_book)
      end
    end

    describe '.by_genre' do
      it 'filters books by genre' do
        expect(Book.by_genre('Fiction')).to include(fiction_book)
        expect(Book.by_genre('Fiction')).not_to include(science_book)
      end

      it 'returns all books when genre is nil' do
        expect(Book.by_genre(nil).count).to eq(Book.count)
      end
    end

    describe '.search' do
      let!(:ruby_book) { create(:book, title: 'Ruby Programming', author: 'John Doe') }
      let!(:python_book) { create(:book, title: 'Python Basics', author: 'Jane Smith') }

      it 'searches by title' do
        expect(Book.search('Ruby')).to include(ruby_book)
        expect(Book.search('Ruby')).not_to include(python_book)
      end

      it 'searches by author' do
        expect(Book.search('Jane')).to include(python_book)
        expect(Book.search('Jane')).not_to include(ruby_book)
      end

      it 'is case insensitive' do
        expect(Book.search('ruby')).to include(ruby_book)
        expect(Book.search('RUBY')).to include(ruby_book)
      end

      it 'returns all books when query is nil' do
        expect(Book.search(nil).count).to eq(Book.count)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  let(:member) { create(:user, :member) }
  let(:librarian) { create(:user, :librarian) }
  let(:book) { create(:book, available_copies: 5) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    it 'validates user must be a member' do
      borrowing = build(:borrowing, user: librarian, book: book)
      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:user]).to include("must be a member to borrow books")
    end

    it 'allows members to borrow' do
      borrowing = build(:borrowing, user: member, book: book)
      expect(borrowing).to be_valid
    end

    it 'prevents borrowing the same book twice concurrently' do
      create(:borrowing, user: member, book: book)
      duplicate = build(:borrowing, user: member, book: book)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:book]).to include("is already borrowed by this user")
    end

    it 'allows borrowing the same book after returning' do
      borrowing = create(:borrowing, user: member, book: book)
      borrowing.return_book!

      new_borrowing = build(:borrowing, user: member, book: book)
      expect(new_borrowing).to be_valid
    end

    it 'prevents borrowing when book is not available' do
      unavailable_book = create(:book, available_copies: 0)
      borrowing = build(:borrowing, user: member, book: unavailable_book)

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:book]).to include("is not available for borrowing")
    end
  end

  describe 'callbacks' do
    it 'sets borrowed_at automatically' do
      borrowing = create(:borrowing, user: member, book: book, borrowed_at: nil)
      expect(borrowing.borrowed_at).to be_present
    end

    it 'sets due_date to 14 days from borrowed_at' do
      borrowed_time = Time.current
      borrowing = create(:borrowing, user: member, book: book, borrowed_at: borrowed_time)
      expect(borrowing.due_date).to be_within(1.second).of(borrowed_time + 14.days)
    end

    it 'decrements available_copies on create' do
      expect {
        create(:borrowing, user: member, book: book)
      }.to change { book.reload.available_copies }.by(-1)
    end

    it 'increments available_copies on return' do
      borrowing = create(:borrowing, user: member, book: book)
      expect {
        borrowing.return_book!
      }.to change { book.reload.available_copies }.by(1)
    end
  end

  describe 'scopes' do
    let!(:active_borrowing) { create(:borrowing, user: member, book: book) }
    let!(:returned_borrowing) { create(:borrowing, :returned, user: member) }
    let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member) }

    describe '.active' do
      it 'returns only active borrowings' do
        expect(Borrowing.active).to include(active_borrowing, overdue_borrowing)
        expect(Borrowing.active).not_to include(returned_borrowing)
      end
    end

    describe '.returned' do
      it 'returns only returned borrowings' do
        expect(Borrowing.returned).to include(returned_borrowing)
        expect(Borrowing.returned).not_to include(active_borrowing, overdue_borrowing)
      end
    end

    describe '.overdue' do
      it 'returns only overdue borrowings' do
        expect(Borrowing.overdue).to include(overdue_borrowing)
        expect(Borrowing.overdue).not_to include(active_borrowing, returned_borrowing)
      end
    end

    describe '.for_user' do
      let(:other_user) { create(:user, :member) }
      let!(:other_borrowing) { create(:borrowing, user: other_user) }

      it 'returns borrowings for specific user' do
        expect(Borrowing.for_user(member)).to include(active_borrowing, returned_borrowing, overdue_borrowing)
        expect(Borrowing.for_user(member)).not_to include(other_borrowing)
      end
    end
  end

  describe '#returned?' do
    it 'returns true when returned_at is present' do
      borrowing = create(:borrowing, :returned, user: member, book: book)
      expect(borrowing.returned?).to be true
    end

    it 'returns false when returned_at is nil' do
      borrowing = create(:borrowing, user: member, book: book)
      expect(borrowing.returned?).to be false
    end
  end

  describe '#overdue?' do
    it 'returns true when due_date is past and not returned' do
      borrowing = create(:borrowing, :overdue, user: member, book: book)
      expect(borrowing.overdue?).to be true
    end

    it 'returns false when due_date is future' do
      borrowing = create(:borrowing, user: member, book: book)
      expect(borrowing.overdue?).to be false
    end

    it 'returns false when returned' do
      borrowing = create(:borrowing, :overdue, user: member, book: book)
      borrowing.return_book!
      expect(borrowing.overdue?).to be false
    end
  end

  describe '#return_book!' do
    it 'sets returned_at to current time' do
      borrowing = create(:borrowing, user: member, book: book)
      borrowing.return_book!
      expect(borrowing.returned_at).to be_within(1.second).of(Time.current)
    end
  end
end

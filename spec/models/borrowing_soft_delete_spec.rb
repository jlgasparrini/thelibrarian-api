require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe 'soft delete' do
    let(:user) { create(:user, :member) }
    let(:book) { create(:book) }
    let(:borrowing) { create(:borrowing, user: user, book: book) }

    describe '#destroy' do
      it 'soft deletes the borrowing instead of removing it' do
        borrowing # create the borrowing first
        expect { borrowing.destroy }.not_to change(Borrowing.with_deleted, :count)
      end

      it 'sets deleted_at timestamp' do
        borrowing.destroy
        expect(borrowing.deleted_at).not_to be_nil
      end

      it 'excludes soft deleted borrowings from default scope' do
        borrowing.destroy
        expect(Borrowing.all).not_to include(borrowing)
      end

      it 'can be found with with_deleted scope' do
        borrowing.destroy
        expect(Borrowing.with_deleted).to include(borrowing)
      end
    end

    describe '#really_destroy!' do
      it 'permanently deletes the borrowing' do
        borrowing_id = borrowing.id
        borrowing.really_destroy!
        expect(Borrowing.with_deleted.find_by(id: borrowing_id)).to be_nil
      end
    end

    describe '#restore' do
      it 'restores a soft deleted borrowing' do
        borrowing.destroy
        borrowing.restore
        expect(Borrowing.all).to include(borrowing)
        expect(borrowing.deleted_at).to be_nil
      end
    end

    describe '.only_deleted' do
      it 'returns only soft deleted borrowings' do
        deleted_borrowing = create(:borrowing, user: user, book: book)
        active_borrowing = create(:borrowing, user: user, book: create(:book))

        deleted_borrowing.destroy

        expect(Borrowing.only_deleted).to include(deleted_borrowing)
        expect(Borrowing.only_deleted).not_to include(active_borrowing)
      end
    end

    describe 'scopes with soft delete' do
      let!(:active_borrowing) { create(:borrowing, user: user, book: book) }
      let!(:deleted_borrowing) { create(:borrowing, user: user, book: create(:book)) }

      before { deleted_borrowing.destroy }

      it 'active scope excludes soft deleted borrowings' do
        expect(Borrowing.active).to include(active_borrowing)
        expect(Borrowing.active).not_to include(deleted_borrowing)
      end

      it 'for_user scope excludes soft deleted borrowings' do
        expect(Borrowing.for_user(user)).to include(active_borrowing)
        expect(Borrowing.for_user(user)).not_to include(deleted_borrowing)
      end
    end
  end
end

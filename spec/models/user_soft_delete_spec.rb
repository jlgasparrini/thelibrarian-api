require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'soft delete' do
    let(:user) { create(:user, :member, email: 'test@example.com') }

    describe '#destroy' do
      it 'soft deletes the user instead of removing it' do
        user # create the user first
        expect { user.destroy }.not_to change(User.with_deleted, :count)
      end

      it 'sets deleted_at timestamp' do
        user.destroy
        expect(user.deleted_at).not_to be_nil
      end

      it 'excludes soft deleted users from default scope' do
        user.destroy
        expect(User.all).not_to include(user)
      end

      it 'can be found with with_deleted scope' do
        user.destroy
        expect(User.with_deleted).to include(user)
      end
    end

    describe '#really_destroy!' do
      it 'permanently deletes the user' do
        user_id = user.id
        user.really_destroy!
        expect(User.with_deleted.find_by(id: user_id)).to be_nil
      end
    end

    describe '#restore' do
      it 'restores a soft deleted user' do
        user.destroy
        user.restore
        expect(User.all).to include(user)
        expect(user.deleted_at).to be_nil
      end
    end

    describe '.only_deleted' do
      it 'returns only soft deleted users' do
        deleted_user = create(:user, :member, email: 'deleted@example.com')
        active_user = create(:user, :member, email: 'active@example.com')

        deleted_user.destroy

        expect(User.only_deleted).to include(deleted_user)
        expect(User.only_deleted).not_to include(active_user)
      end
    end

    describe 'with associations' do
      let!(:borrowing) { create(:borrowing, user: user) }

      it 'soft deletes associated borrowings when user is destroyed' do
        user.destroy
        expect(Borrowing.with_deleted.find(borrowing.id).deleted_at).not_to be_nil
      end

      it 'preserves borrowing history after user deletion' do
        borrowing_id = borrowing.id
        user.destroy

        deleted_borrowing = Borrowing.with_deleted.find(borrowing_id)
        expect(deleted_borrowing.user_id).to eq(user.id)
      end
    end

    describe 'email uniqueness with soft delete' do
      it 'allows creating a user with same email after soft delete' do
        email = user.email
        user.destroy

        new_user = build(:user, :member, email: email)
        expect(new_user).to be_valid
      end

      it 'prevents creating a user with same email as active user' do
        email = user.email
        new_user = build(:user, :member, email: email)
        expect(new_user).not_to be_valid
      end

      it 'allows multiple soft deleted users with same email' do
        email = 'duplicate@example.com'
        user1 = create(:user, :member, email: email)
        user1.destroy

        user2 = create(:user, :member, email: email)
        user2.destroy

        expect(User.only_deleted.where(email: email).count).to eq(2)
      end
    end

    describe 'authentication with soft delete' do
      describe '#active_for_authentication?' do
        it 'returns true for active users' do
          expect(user.active_for_authentication?).to be true
        end

        it 'returns false for soft deleted users' do
          user.destroy
          expect(user.active_for_authentication?).to be false
        end

        it 'returns true for restored users' do
          user.destroy
          user.restore
          expect(user.active_for_authentication?).to be true
        end
      end

      describe '#inactive_message' do
        it 'returns :deleted_account for soft deleted users' do
          user.destroy
          expect(user.inactive_message).to eq(:deleted_account)
        end

        it 'returns default message for active users' do
          expect(user.inactive_message).not_to eq(:deleted_account)
        end
      end

      describe '#deleted?' do
        it 'returns false for active users' do
          expect(user.deleted?).to be false
        end

        it 'returns true for soft deleted users' do
          user.destroy
          expect(user.deleted?).to be true
        end

        it 'returns false for restored users' do
          user.destroy
          user.restore
          expect(user.deleted?).to be false
        end
      end
    end

    describe 'Devise integration' do
      it 'prevents deleted users from signing in' do
        user.destroy

        # Attempt to find user for authentication
        found_user = User.find_for_database_authentication(email: user.email)

        # Should not find deleted user in default scope
        expect(found_user).to be_nil
      end

      it 'allows active users to sign in' do
        found_user = User.find_for_database_authentication(email: user.email)
        expect(found_user).to eq(user)
      end
    end
  end
end

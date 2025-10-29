require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  let(:member) { create(:user, :member) }
  let(:librarian) { create(:user, :librarian) }
  let(:other_user) { create(:user, :member) }

  permissions :show? do
    it 'allows users to view their own profile' do
      expect(subject).to permit(member, member)
    end

    it 'denies users from viewing other profiles' do
      expect(subject).not_to permit(member, other_user)
    end

    it 'allows librarians to view their own profile' do
      expect(subject).to permit(librarian, librarian)
    end
  end

  permissions :update? do
    it 'allows users to update their own profile' do
      expect(subject).to permit(member, member)
    end

    it 'denies users from updating other profiles' do
      expect(subject).not_to permit(member, other_user)
    end
  end

  permissions :destroy? do
    it 'denies members from deleting users' do
      expect(subject).not_to permit(member, other_user)
    end

    it 'allows librarians to delete users' do
      expect(subject).to permit(librarian, other_user)
    end
  end

  permissions :index? do
    it 'denies members from listing all users' do
      expect(subject).not_to permit(member, User)
    end

    it 'allows librarians to list all users' do
      expect(subject).to permit(librarian, User)
    end
  end

  describe 'Scope' do
    it 'returns only the user for members' do
      scope = Pundit.policy_scope!(member, User)
      expect(scope).to eq([ member ])
    end

    it 'returns all users for librarians' do
      member
      librarian
      other_user

      scope = Pundit.policy_scope!(librarian, User)
      expect(scope.count).to eq(User.count)
    end
  end
end

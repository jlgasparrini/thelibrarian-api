require 'rails_helper'

RSpec.describe BookPolicy, type: :policy do
  subject { described_class }

  let(:member) { create(:user, :member) }
  let(:librarian) { create(:user, :librarian) }
  let(:book) { create(:book) }

  permissions :index?, :show? do
    it 'allows members to view books' do
      expect(subject).to permit(member, book)
    end

    it 'allows librarians to view books' do
      expect(subject).to permit(librarian, book)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies members from managing books' do
      expect(subject).not_to permit(member, book)
    end

    it 'allows librarians to manage books' do
      expect(subject).to permit(librarian, book)
    end
  end

  describe 'Scope' do
    it 'returns all books for members' do
      book
      scope = Pundit.policy_scope!(member, Book)
      expect(scope).to include(book)
    end

    it 'returns all books for librarians' do
      book
      scope = Pundit.policy_scope!(librarian, Book)
      expect(scope).to include(book)
    end
  end
end

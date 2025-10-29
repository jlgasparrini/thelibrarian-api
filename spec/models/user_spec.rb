require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }

    describe 'email uniqueness' do
      let(:user) { create(:user, :member, email: 'test@example.com') }

      it 'validates uniqueness of email for active users' do
        duplicate = build(:user, :member, email: user.email)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:email]).to include('has already been taken')
      end

      it 'allows same email after user is soft deleted' do
        user.destroy
        new_user = build(:user, :member, email: user.email)
        expect(new_user).to be_valid
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 0, librarian: 1) }
  end

  describe 'roles' do
    let(:member) { create(:user, :member) }
    let(:librarian) { create(:user, :librarian) }

    it 'creates a member by default' do
      user = create(:user)
      expect(user.member?).to be true
    end

    it 'can be created as a librarian' do
      expect(librarian.librarian?).to be true
      expect(librarian.member?).to be false
    end

    it 'can be created as a member' do
      expect(member.member?).to be true
      expect(member.librarian?).to be false
    end
  end

  describe 'JWT authentication' do
    it 'includes jwt_authenticatable module' do
      expect(User.devise_modules).to include(:jwt_authenticatable)
    end
  end
end

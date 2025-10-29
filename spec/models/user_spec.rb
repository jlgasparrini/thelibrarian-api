require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:role) }
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

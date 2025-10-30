require 'rails_helper'

RSpec.describe Audited::Audit, type: :model do
  describe 'User auditing' do
    let(:user) { create(:user, :member, email: 'test@example.com') }

    it 'creates an audit when user is created' do
      expect { user }.to change(Audited::Audit, :count).by(1)
    end

    it 'records the action as create' do
      user
      audit = Audited::Audit.last
      expect(audit.action).to eq('create')
    end

    it 'records the auditable type and id' do
      user
      audit = Audited::Audit.last
      expect(audit.auditable_type).to eq('User')
      expect(audit.auditable_id).to eq(user.id)
    end

    it 'creates an audit when user is updated' do
      user
      expect {
        user.update(email: 'newemail@example.com')
      }.to change(Audited::Audit, :count).by(1)
    end

    it 'records changed attributes' do
      user
      user.update(email: 'newemail@example.com')
      audit = Audited::Audit.last
      expect(audit.audited_changes).to include('email')
      expect(audit.audited_changes['email']).to eq([ 'test@example.com', 'newemail@example.com' ])
    end

    it 'creates an audit when user is destroyed' do
      user
      expect {
        user.destroy
      }.to change(Audited::Audit, :count).by(1)
    end

    it 'does not audit sensitive fields' do
      user.update(password: 'newpassword123')
      audit = Audited::Audit.last
      expect(audit.audited_changes).not_to include('encrypted_password')
      expect(audit.audited_changes).not_to include('reset_password_token')
    end

    it 'tracks role changes' do
      user
      user.update(role: :librarian)
      audit = Audited::Audit.last
      expect(audit.audited_changes['role']).to eq([ 0, 1 ]) # enum values
    end
  end

  describe 'Book auditing' do
    let(:book) { create(:book, title: 'Original Title') }

    it 'creates an audit when book is created' do
      expect { book }.to change(Audited::Audit, :count).by(1)
    end

    it 'creates an audit when book is updated' do
      book
      expect {
        book.update(title: 'New Title')
      }.to change(Audited::Audit, :count).by(1)
    end

    it 'records all changed attributes' do
      book
      book.update(title: 'New Title', available_copies: 3)
      audit = Audited::Audit.last
      expect(audit.audited_changes).to include('title', 'available_copies')
    end

    it 'creates an audit when book is destroyed' do
      book
      expect {
        book.destroy
      }.to change(Audited::Audit, :count).by(1)
    end

    it 'tracks soft delete' do
      book
      book.destroy
      audit = Audited::Audit.last
      expect(audit.action).to eq('destroy') # Audited records destroy action
      expect(audit.auditable_id).to eq(book.id)
    end
  end

  describe 'Borrowing auditing' do
    let!(:user) { create(:user, :member) }
    let!(:book) { create(:book) }
    let(:borrowing) { create(:borrowing, user: user, book: book) }

    it 'creates an audit when borrowing is created' do
      # User and book already created, so only borrowing audit is new
      expect { borrowing }.to change(Audited::Audit, :count).by(1)
    end

    it 'associates audit with user' do
      borrowing
      audit = Audited::Audit.last
      expect(audit.associated_type).to eq('User')
      expect(audit.associated_id).to eq(user.id)
    end

    it 'creates an audit when borrowing is returned' do
      borrowing
      expect {
        borrowing.return_book!
      }.to change(Audited::Audit, :count).by(1)
    end

    it 'tracks returned_at changes' do
      borrowing
      borrowing.return_book!
      audit = Audited::Audit.last
      expect(audit.audited_changes).to include('returned_at')
      expect(audit.audited_changes['returned_at'][0]).to be_nil
      expect(audit.audited_changes['returned_at'][1]).to be_present
    end
  end

  describe 'Audit queries' do
    let(:user) { create(:user, :member, email: 'original@example.com') }
    let(:book) { create(:book, title: 'Original Title') }

    it 'can retrieve all audits for a user' do
      user.update(email: 'new@example.com')
      user.update(role: :librarian)

      expect(user.audits.count).to eq(3) # create + 2 updates
    end

    it 'can retrieve all audits for a book' do
      book # create
      book.update(title: 'New Title')

      expect(book.audits.count).to eq(2) # create + 1 update
    end

    it 'can retrieve audits by action' do
      user
      book

      create_audits = Audited::Audit.where(action: 'create')
      expect(create_audits.count).to eq(2)
    end

    it 'can retrieve recent audits' do
      user
      book

      recent_audits = Audited::Audit.order(created_at: :desc).limit(2)
      expect(recent_audits.count).to eq(2)
    end
  end

  describe 'Audit history' do
    let(:book) { create(:book, title: 'Version 1') }

    it 'maintains version history' do
      book.update(title: 'Version 2')
      book.update(title: 'Version 3')

      audits = book.audits.order(:version)
      expect(audits.map(&:version)).to eq([ 1, 2, 3 ])
    end

    it 'can reconstruct previous state' do
      original_title = book.title
      book.update(title: 'New Title')

      first_audit = book.audits.first
      expect(first_audit.action).to eq('create')
      expect(first_audit.audited_changes['title']).to eq(original_title)
    end
  end
end

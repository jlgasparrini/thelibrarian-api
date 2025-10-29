class Borrowing < ApplicationRecord
  # Soft delete
  acts_as_paranoid

  belongs_to :user
  belongs_to :book, counter_cache: true

  # Validations
  validates :borrowed_at, presence: true
  validates :due_date, presence: true
  validate :user_must_be_member
  validate :cannot_borrow_same_book_twice_concurrently
  validate :book_must_be_available, on: :create

  # Callbacks
  before_validation :set_borrowed_at, on: :create
  before_validation :set_due_date, on: :create
  after_create :decrement_available_copies
  after_update :increment_available_copies, if: :saved_change_to_returned_at?

  # Scopes
  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { active.where("due_date < ?", Time.current) }
  scope :for_user, ->(user) { where(user: user) }
  scope :due_today, -> { active.where("DATE(due_date) = ?", Date.today) }
  scope :due_soon, -> { active.where("due_date <= ?", AppConstants::DUE_SOON_DAYS.days.from_now) }

  # Instance methods
  def returned?
    returned_at.present?
  end

  def overdue?
    !returned? && due_date < Time.current
  end

  def return_book!
    update!(returned_at: Time.current)
  end

  private

  def set_borrowed_at
    self.borrowed_at ||= Time.current
  end

  def set_due_date
    self.due_date ||= (borrowed_at || Time.current) + AppConstants::BORROWING_PERIOD_DAYS.days
  end

  def user_must_be_member
    if user && !user.member?
      errors.add(:user, "must be a member to borrow books")
    end
  end

  def cannot_borrow_same_book_twice_concurrently
    if user && book
      existing = Borrowing.active.where(user: user, book: book).where.not(id: id)
      if existing.exists?
        errors.add(:book, "is already borrowed by this user")
      end
    end
  end

  def book_must_be_available
    if book && book.available_copies <= 0
      errors.add(:book, "is not available for borrowing")
    end
  end

  def decrement_available_copies
    # Use with_lock to prevent race conditions
    book.with_lock do
      if book.available_copies > 0
        book.decrement!(:available_copies)
      else
        raise ActiveRecord::RecordInvalid, "Book is no longer available"
      end
    end
  end

  def increment_available_copies
    book.with_lock do
      book.increment!(:available_copies)
    end
  end
end

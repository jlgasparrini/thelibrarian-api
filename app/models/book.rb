class Book < ApplicationRecord
  # Soft delete
  acts_as_paranoid

  # Audit logging
  audited

  # Associations
  has_many :borrowings, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: { case_sensitive: false }
  validates :total_copies, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :available_copies, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :available_copies_cannot_exceed_total_copies
  validate :total_copies_cannot_be_less_than_borrowed, on: :update, if: :will_save_change_to_total_copies?

  # Callbacks
  before_validation :initialize_available_copies, on: :create
  before_save :reconcile_total_and_available_with_borrowed, if: -> { will_save_change_to_total_copies? && persisted? }

  # Scopes
  scope :available, -> { where("available_copies > 0") }
  scope :by_genre, ->(genre) { where(genre: genre) if genre.present? }
  scope :search, ->(query) {
    where("title ILIKE :query OR author ILIKE :query OR isbn ILIKE :query", query: "%#{query}%") if query.present?
  }
  scope :sorted_by, ->(sort_param) {
    case sort_param
    when "title"
      order(title: :asc)
    when "author"
      order(author: :asc)
    when "created_at"
      order(created_at: :desc)
    else
      order(created_at: :desc)
    end
  }

  private

  def available_copies_cannot_exceed_total_copies
    # Skip this validation if we're updating total_copies (will be reconciled in before_save)
    return if persisted? && will_save_change_to_total_copies?

    if available_copies.present? && total_copies.present? && available_copies > total_copies
      errors.add(:available_copies, "cannot exceed total copies")
    end
  end

  def total_copies_cannot_be_less_than_borrowed
    active_borrowings_count = borrowings.active.count
    if total_copies < active_borrowings_count
      errors.add(:total_copies, "cannot be less than active borrowings (#{active_borrowings_count})")
    end
  end

  def initialize_available_copies
    self.available_copies = total_copies if available_copies.nil? && total_copies.present?
  end

  def reconcile_total_and_available_with_borrowed
    # When total_copies changes, recalculate available_copies
    # available = total - borrowed
    active_borrowings_count = borrowings.active.count
    self.available_copies = total_copies - active_borrowings_count
  end
end

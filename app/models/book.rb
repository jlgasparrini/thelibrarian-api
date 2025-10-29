class Book < ApplicationRecord
  # Soft delete
  acts_as_paranoid

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
    if available_copies.present? && total_copies.present? && available_copies > total_copies
      errors.add(:available_copies, "cannot exceed total copies")
    end
  end
end

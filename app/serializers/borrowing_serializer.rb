class BorrowingSerializer
  # For list views with book and user info
  def self.with_relations(borrowing)
    {
      id: borrowing.id,
      borrowed_at: borrowing.borrowed_at,
      due_date: borrowing.due_date,
      returned_at: borrowing.returned_at,
      overdue: borrowing.overdue?,
      book: BookSerializer.minimal(borrowing.book),
      user: UserSerializer.minimal(borrowing.user)
    }
  end

  # For detailed views
  def self.detailed(borrowing)
    {
      id: borrowing.id,
      borrowed_at: borrowing.borrowed_at,
      due_date: borrowing.due_date,
      returned_at: borrowing.returned_at,
      overdue: borrowing.overdue?,
      book: BookSerializer.with_isbn(borrowing.book),
      user: UserSerializer.minimal(borrowing.user)
    }
  end

  # For dashboard views (minimal info)
  def self.dashboard(borrowing)
    {
      id: borrowing.id,
      borrowed_at: borrowing.borrowed_at,
      due_date: borrowing.due_date,
      returned_at: borrowing.returned_at,
      "overdue?": borrowing.overdue?,
      book: BookSerializer.with_isbn(borrowing.book)
    }
  end

  # For history views
  def self.history(borrowing)
    {
      id: borrowing.id,
      borrowed_at: borrowing.borrowed_at,
      due_date: borrowing.due_date,
      returned_at: borrowing.returned_at,
      book: BookSerializer.minimal(borrowing.book)
    }
  end
end

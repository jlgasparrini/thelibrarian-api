class DashboardService
  def initialize(user)
    @user = user
  end

  def call
    @user.librarian? ? librarian_dashboard : member_dashboard
  end

  private

  attr_reader :user

  def librarian_dashboard
    {
      dashboard: {
        total_books: Book.count,
        total_available_books: Book.available.count,
        total_borrowed_books: Borrowing.active.count,
        books_due_today: Borrowing.due_today.count,
        overdue_books: Borrowing.overdue.count,
        total_members: User.member.count,
        members_with_overdue_books: users_with_overdue_books.count,
        recent_borrowings: recent_borrowings_data,
        popular_books: popular_books_data,
        overdue_borrowings: overdue_borrowings_data
      }
    }
  end

  def member_dashboard
    user_borrowings = user.borrowings.includes(:book)
    active_borrowings = user_borrowings.active.order(due_date: :asc)

    {
      dashboard: {
        active_borrowings_count: active_borrowings.count,
        overdue_borrowings_count: user_borrowings.overdue.count,
        books_due_soon: user_borrowings.due_soon.count,
        borrowed_books: active_borrowings.map { |b| BorrowingSerializer.dashboard(b) },
        borrowing_history: borrowing_history(user_borrowings)
      }
    }
  end

  # Librarian helper methods

  def users_with_overdue_books
    User.member.joins(:borrowings).merge(Borrowing.overdue).distinct
  end

  def recent_borrowings_data
    Borrowing.includes(:book, :user)
             .order(created_at: :desc)
             .limit(AppConstants::DASHBOARD_RECENT_LIMIT)
             .map { |b| BorrowingSerializer.with_relations(b) }
  end

  def popular_books_data
    Book.where("borrowings_count > 0")
        .order(borrowings_count: :desc)
        .limit(AppConstants::DASHBOARD_POPULAR_LIMIT)
        .map { |b| BookSerializer.popular(b) }
  end

  def overdue_borrowings_data
    Borrowing.overdue
             .includes(:book, :user)
             .order(due_date: :asc)
             .limit(AppConstants::DASHBOARD_OVERDUE_LIMIT)
             .map { |b| BorrowingSerializer.with_relations(b) }
  end

  # Member helper methods
  def borrowing_history(user_borrowings)
    user_borrowings.returned
                   .order(returned_at: :desc)
                   .limit(AppConstants::DASHBOARD_RECENT_LIMIT)
                   .map { |b| BorrowingSerializer.history(b) }
  end
end

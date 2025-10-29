module Api
  module V1
    class DashboardsController < ApplicationController
      before_action :authenticate_user!

      def show
        authorize :dashboard, :show?

        if current_user.librarian?
          render json: librarian_dashboard, status: :ok
        else
          render json: member_dashboard, status: :ok
        end
      end

      private

      def librarian_dashboard
        {
          dashboard: {
            total_books: Book.count,
            total_available_books: Book.where("available_copies > 0").count,
            total_borrowed_books: Borrowing.active.count,
            books_due_today: borrowings_due_today.count,
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
        user_borrowings = current_user.borrowings.includes(:book)
        active_borrowings = user_borrowings.active.order(due_date: :asc)
        overdue_borrowings = user_borrowings.overdue.order(due_date: :asc)

        {
          dashboard: {
            active_borrowings_count: active_borrowings.count,
            overdue_borrowings_count: overdue_borrowings.count,
            books_due_soon: active_borrowings.where("due_date <= ?", 3.days.from_now).count,
            borrowed_books: active_borrowings.as_json(
              include: {
                book: {
                  only: [ :id, :title, :author, :isbn ]
                }
              },
              only: [ :id, :borrowed_at, :due_date ],
              methods: [ :overdue? ]
            ),
            borrowing_history: user_borrowings.returned.order(returned_at: :desc).limit(10).as_json(
              include: {
                book: {
                  only: [ :id, :title, :author ]
                }
              },
              only: [ :id, :borrowed_at, :due_date, :returned_at ]
            )
          }
        }
      end

      def borrowings_due_today
        Borrowing.active.where("DATE(due_date) = ?", Date.today)
      end

      def users_with_overdue_books
        User.member.joins(:borrowings).merge(Borrowing.overdue).distinct
      end

      def recent_borrowings_data
        Borrowing.includes(:book, :user)
                 .order(created_at: :desc)
                 .limit(10)
                 .as_json(
                   include: {
                     book: { only: [ :id, :title, :author ] },
                     user: { only: [ :id, :email ] }
                   },
                   only: [ :id, :borrowed_at, :due_date, :returned_at ]
                 )
      end

      def popular_books_data
        Book.where("borrowings_count > 0")
            .order(borrowings_count: :desc)
            .limit(10)
            .as_json(only: [ :id, :title, :author, :borrowings_count, :available_copies ])
      end

      def overdue_borrowings_data
        Borrowing.overdue
                 .includes(:book, :user)
                 .order(due_date: :asc)
                 .limit(10)
                 .as_json(
                   include: {
                     book: { only: [ :id, :title, :author ] },
                     user: { only: [ :id, :email ] }
                   },
                   only: [ :id, :borrowed_at, :due_date ],
                   methods: [ :overdue? ]
                 )
      end
    end
  end
end

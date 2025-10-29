module Api
  module V1
    class BorrowingsController < ApplicationController
      include JsonResponse

      before_action :authenticate_user!
      before_action :set_borrowing, only: [ :show, :update ]

      def index
        @borrowings = policy_scope(Borrowing).includes(:book, :user)

        # Filter by status
        @borrowings = @borrowings.active if params[:status] == "active"
        @borrowings = @borrowings.returned if params[:status] == "returned"
        @borrowings = @borrowings.overdue if params[:status] == "overdue"

        # Order by most recent first
        @borrowings = @borrowings.order(created_at: :desc)

        authorize @borrowings

        # Pagination
        pagy, borrowings = pagy(@borrowings, items: params[:per_page] || AppConstants::DEFAULT_PER_PAGE)

        render_paginated_collection(
          borrowings,
          pagy,
          serializer: ->(b) { BorrowingSerializer.with_relations(b) }
        )
      end

      def show
        authorize @borrowing
        render_resource(
          BorrowingSerializer.detailed(@borrowing),
          key: :borrowing
        )
      end

      def create
        @borrowing = current_user.borrowings.build(borrowing_params)
        authorize @borrowing

        if @borrowing.save
          render_created(
            BorrowingSerializer.detailed(@borrowing),
            key: :borrowing,
            message: "Book borrowed successfully"
          )
        else
          render_errors(@borrowing.errors.full_messages)
        end
      end

      def update
        authorize @borrowing

        if params[:action_type] == "return"
          if @borrowing.return_book!
            render_resource(
              BorrowingSerializer.detailed(@borrowing),
              key: :borrowing,
              message: "Book returned successfully"
            )
          else
            render_errors(@borrowing.errors.full_messages)
          end
        else
          render_errors(["Invalid action"], status: :bad_request)
        end
      end

      def overdue
        @borrowings = policy_scope(Borrowing).overdue.includes(:book, :user).order(due_date: :asc)
        authorize @borrowings

        # Pagination
        pagy, borrowings = pagy(@borrowings, items: params[:per_page] || AppConstants::DEFAULT_PER_PAGE)

        render_paginated_collection(
          borrowings,
          pagy,
          serializer: ->(b) { BorrowingSerializer.with_relations(b) }
        )
      end

      private

      def set_borrowing
        @borrowing = Borrowing.find(params[:id])
      end

      def borrowing_params
        params.require(:borrowing).permit(:book_id)
      end
    end
  end
end

module Api
  module V1
    class BorrowingsController < ApplicationController
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

        render json: { borrowings: @borrowings.as_json(include: { book: { only: [ :id, :title, :author ] }, user: { only: [ :id, :email ] } }) }, status: :ok
      end

      def show
        authorize @borrowing
        render json: { borrowing: @borrowing.as_json(include: { book: { only: [ :id, :title, :author, :isbn ] }, user: { only: [ :id, :email ] } }) }, status: :ok
      end

      def create
        @borrowing = current_user.borrowings.build(borrowing_params)
        authorize @borrowing

        if @borrowing.save
          render json: { borrowing: @borrowing, message: "Book borrowed successfully" }, status: :created
        else
          render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @borrowing

        if params[:action_type] == "return"
          if @borrowing.return_book!
            render json: { borrowing: @borrowing, message: "Book returned successfully" }, status: :ok
          else
            render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_content
          end
        else
          render json: { error: "Invalid action" }, status: :bad_request
        end
      end

      def overdue
        @borrowings = policy_scope(Borrowing).overdue.includes(:book, :user).order(due_date: :asc)
        authorize @borrowings

        render json: { borrowings: @borrowings.as_json(include: { book: { only: [ :id, :title, :author ] }, user: { only: [ :id, :email ] } }) }, status: :ok
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

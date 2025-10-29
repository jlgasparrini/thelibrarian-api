module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_book, only: [ :show, :update, :destroy ]

      def index
        @books = Book.all
        @books = @books.search(params[:query]) if params[:query].present?
        @books = @books.by_genre(params[:genre]) if params[:genre].present?
        @books = @books.available if params[:available] == "true"

        # Sorting
        @books = case params[:sort]
        when "title"
          @books.order(title: :asc)
        when "author"
          @books.order(author: :asc)
        when "created_at"
          @books.order(created_at: :desc)
        else
          @books.order(created_at: :desc)
        end

        authorize @books

        # Pagination
        pagy, books = pagy(@books, items: params[:per_page] || 25)

        render json: {
          books: books,
          pagination: pagy_metadata(pagy)
        }, status: :ok
      end

      def show
        authorize @book
        render json: { book: @book }, status: :ok
      end

      def create
        @book = Book.new(book_params)
        authorize @book

        if @book.save
          render json: { book: @book, message: "Book created successfully" }, status: :created
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @book

        if @book.update(book_params)
          render json: { book: @book, message: "Book updated successfully" }, status: :ok
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        authorize @book

        @book.destroy
        render json: { message: "Book deleted successfully" }, status: :ok
      end

      private

      def set_book
        @book = Book.find(params[:id])
      end

      def book_params
        params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies, :available_copies)
      end
    end
  end
end

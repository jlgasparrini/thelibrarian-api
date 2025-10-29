class AddBorrowingsCountToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :borrowings_count, :integer, default: 0, null: false

    # Backfill existing counts
    reversible do |dir|
      dir.up do
        Book.find_each do |book|
          Book.reset_counters(book.id, :borrowings)
        end
      end
    end
  end
end

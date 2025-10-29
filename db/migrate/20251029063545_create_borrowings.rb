class CreateBorrowings < ActiveRecord::Migration[8.0]
  def change
    create_table :borrowings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :due_date, null: false
      t.datetime :returned_at

      t.timestamps
    end

    # Indexes for performance
    add_index :borrowings, :borrowed_at
    add_index :borrowings, :due_date
    add_index :borrowings, :returned_at
    add_index :borrowings, [ :user_id, :book_id, :returned_at ], name: 'index_borrowings_on_user_book_returned'
  end
end

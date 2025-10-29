class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :genre
      t.string :isbn, null: false
      t.integer :total_copies, null: false, default: 1
      t.integer :available_copies, null: false, default: 1

      t.timestamps
    end

    add_index :books, :isbn, unique: true
    add_index :books, :title
    add_index :books, :author
    add_index :books, :genre
  end
end

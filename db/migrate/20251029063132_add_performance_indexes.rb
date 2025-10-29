class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Index for role-based queries (librarian vs member checks)
    add_index :users, :role

    # Index for available books queries
    add_index :books, :available_copies

    # Index for JWT token expiration cleanup
    add_index :jwt_denylist, :exp

    # Enable pg_trgm extension for trigram-based text search
    # This significantly improves ILIKE query performance
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    
    # Remove old B-tree indexes on title and author
    remove_index :books, :title
    remove_index :books, :author
    
    # Add GIN indexes with trigram operator class for better ILIKE performance
    add_index :books, :title, opclass: :gin_trgm_ops, using: :gin, name: 'index_books_on_title_gin'
    add_index :books, :author, opclass: :gin_trgm_ops, using: :gin, name: 'index_books_on_author_gin'
  end
end

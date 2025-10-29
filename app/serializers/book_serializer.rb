class BookSerializer
  # Minimal version for nested responses
  def self.minimal(book)
    {
      id: book.id,
      title: book.title,
      author: book.author
    }
  end

  # With ISBN for detailed views
  def self.with_isbn(book)
    {
      id: book.id,
      title: book.title,
      author: book.author,
      isbn: book.isbn
    }
  end

  # For popular books list
  def self.popular(book)
    {
      id: book.id,
      title: book.title,
      author: book.author,
      borrowings_count: book.borrowings_count,
      available_copies: book.available_copies
    }
  end
end

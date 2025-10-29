# Library Management System - Seed Data
# This file populates the database with demo data for development and testing

puts "🌱 Starting seed process..."

# Clear existing data (only in development)
if Rails.env.development?
  puts "🗑️  Cleaning database..."
  Borrowing.destroy_all
  Book.destroy_all
  User.destroy_all
  puts "✅ Database cleaned"
end

# Create demo users
puts "\n👥 Creating users..."

librarian = User.find_or_create_by!(email: "admin@library.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = :librarian
end
puts "✅ Librarian created: #{librarian.email}"

member1 = User.find_or_create_by!(email: "member@library.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = :member
end
puts "✅ Member 1 created: #{member1.email}"

member2 = User.find_or_create_by!(email: "john.doe@library.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = :member
end
puts "✅ Member 2 created: #{member2.email}"

member3 = User.find_or_create_by!(email: "jane.smith@library.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = :member
end
puts "✅ Member 3 created: #{member3.email}"

# Create books
puts "\n📚 Creating books..."

books_data = [
  # Programming
  { title: "Clean Code", author: "Robert C. Martin", genre: "Programming", isbn: "978-0132350884", copies: 5 },
  { title: "The Pragmatic Programmer", author: "Andrew Hunt", genre: "Programming", isbn: "978-0135957059", copies: 3 },
  { title: "Design Patterns", author: "Gang of Four", genre: "Programming", isbn: "978-0201633610", copies: 4 },
  { title: "Refactoring", author: "Martin Fowler", genre: "Programming", isbn: "978-0134757599", copies: 3 },
  { title: "Code Complete", author: "Steve McConnell", genre: "Programming", isbn: "978-0735619678", copies: 2 },

  # Science Fiction
  { title: "Dune", author: "Frank Herbert", genre: "Science Fiction", isbn: "978-0441172719", copies: 4 },
  { title: "Foundation", author: "Isaac Asimov", genre: "Science Fiction", isbn: "978-0553293357", copies: 3 },
  { title: "Neuromancer", author: "William Gibson", genre: "Science Fiction", isbn: "978-0441569595", copies: 2 },
  { title: "Snow Crash", author: "Neal Stephenson", genre: "Science Fiction", isbn: "978-0553380958", copies: 3 },
  { title: "The Martian", author: "Andy Weir", genre: "Science Fiction", isbn: "978-0553418026", copies: 5 },

  # Fantasy
  { title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "978-0547928227", copies: 4 },
  { title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", genre: "Fantasy", isbn: "978-0439708180", copies: 6 },
  { title: "The Name of the Wind", author: "Patrick Rothfuss", genre: "Fantasy", isbn: "978-0756404741", copies: 3 },
  { title: "Mistborn", author: "Brandon Sanderson", genre: "Fantasy", isbn: "978-0765350381", copies: 3 },
  { title: "The Way of Kings", author: "Brandon Sanderson", genre: "Fantasy", isbn: "978-0765326355", copies: 2 },

  # Non-Fiction
  { title: "Sapiens", author: "Yuval Noah Harari", genre: "Non-Fiction", isbn: "978-0062316097", copies: 4 },
  { title: "Educated", author: "Tara Westover", genre: "Non-Fiction", isbn: "978-0399590504", copies: 3 },
  { title: "Atomic Habits", author: "James Clear", genre: "Non-Fiction", isbn: "978-0735211292", copies: 5 },
  { title: "Thinking, Fast and Slow", author: "Daniel Kahneman", genre: "Non-Fiction", isbn: "978-0374533557", copies: 3 },
  { title: "The Lean Startup", author: "Eric Ries", genre: "Non-Fiction", isbn: "978-0307887894", copies: 2 },

  # Mystery
  { title: "The Girl with the Dragon Tattoo", author: "Stieg Larsson", genre: "Mystery", isbn: "978-0307454546", copies: 4 },
  { title: "Gone Girl", author: "Gillian Flynn", genre: "Mystery", isbn: "978-0307588371", copies: 3 },
  { title: "The Da Vinci Code", author: "Dan Brown", genre: "Mystery", isbn: "978-0307474278", copies: 3 },
  { title: "Big Little Lies", author: "Liane Moriarty", genre: "Mystery", isbn: "978-0399167065", copies: 2 },
  { title: "The Silent Patient", author: "Alex Michaelides", genre: "Mystery", isbn: "978-1250301697", copies: 4 }
]

books = []
books_data.each do |book_data|
  book = Book.find_or_create_by!(isbn: book_data[:isbn]) do |b|
    b.title = book_data[:title]
    b.author = book_data[:author]
    b.genre = book_data[:genre]
    b.total_copies = book_data[:copies]
    b.available_copies = book_data[:copies]
  end
  books << book
  puts "  ✓ #{book.title} by #{book.author}"
end

puts "✅ #{books.count} books created"

# Create borrowings
puts "\n📖 Creating borrowings..."

# Active borrowings
active_borrowings = [
  { user: member1, book: books[0], days_ago: 5, due_in: 9 },
  { user: member1, book: books[5], days_ago: 3, due_in: 11 },
  { user: member2, book: books[1], days_ago: 7, due_in: 7 },
  { user: member2, book: books[10], days_ago: 2, due_in: 12 },
  { user: member3, book: books[15], days_ago: 10, due_in: 4 }
]

active_borrowings.each do |borrowing_data|
  borrowing = Borrowing.create!(
    user: borrowing_data[:user],
    book: borrowing_data[:book],
    borrowed_at: borrowing_data[:days_ago].days.ago,
    due_date: borrowing_data[:due_in].days.from_now
  )
  puts "  ✓ #{borrowing_data[:user].email} borrowed #{borrowing_data[:book].title}"
end

# Overdue borrowings
overdue_borrowings = [
  { user: member1, book: books[2], days_ago: 20, overdue_by: 6 },
  { user: member3, book: books[20], days_ago: 18, overdue_by: 4 }
]

overdue_borrowings.each do |borrowing_data|
  borrowing = Borrowing.create!(
    user: borrowing_data[:user],
    book: borrowing_data[:book],
    borrowed_at: borrowing_data[:days_ago].days.ago,
    due_date: borrowing_data[:overdue_by].days.ago
  )
  puts "  ✓ #{borrowing_data[:user].email} has overdue: #{borrowing_data[:book].title}"
end

# Returned borrowings (history)
returned_borrowings = [
  { user: member1, book: books[3], borrowed: 30, returned: 25 },
  { user: member1, book: books[6], borrowed: 25, returned: 20 },
  { user: member2, book: books[11], borrowed: 20, returned: 15 },
  { user: member2, book: books[16], borrowed: 15, returned: 10 },
  { user: member3, book: books[21], borrowed: 10, returned: 5 }
]

returned_borrowings.each do |borrowing_data|
  borrowing = Borrowing.create!(
    user: borrowing_data[:user],
    book: borrowing_data[:book],
    borrowed_at: borrowing_data[:borrowed].days.ago,
    due_date: (borrowing_data[:borrowed] - 14).days.ago,
    returned_at: borrowing_data[:returned].days.ago
  )
  puts "  ✓ #{borrowing_data[:user].email} returned #{borrowing_data[:book].title}"
end

puts "✅ #{Borrowing.count} borrowings created"

# Summary
puts "\n" + "="*50
puts "🎉 Seed completed successfully!"
puts "="*50
puts "\n📊 Database Summary:"
puts "  Users: #{User.count} (#{User.librarian.count} librarians, #{User.member.count} members)"
puts "  Books: #{Book.count}"
puts "  Borrowings: #{Borrowing.count}"
puts "    - Active: #{Borrowing.active.count}"
puts "    - Overdue: #{Borrowing.overdue.count}"
puts "    - Returned: #{Borrowing.returned.count}"
puts "\n🔑 Demo Credentials:"
puts "  Librarian: admin@library.com / password"
puts "  Member 1:  member@library.com / password"
puts "  Member 2:  john.doe@library.com / password"
puts "  Member 3:  jane.smith@library.com / password"
puts "\n✨ Ready for frontend integration!"
puts "="*50

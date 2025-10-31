# 📚 Backend User Stories

## 1. 👤 Authentication & Roles
- [x] **As a Member**, I want to register, log in, and log out.  
- [x] **As a Librarian**, I want to log in, and log out.  

**Acceptance Criteria:**
- Using Devise JWT users can sign up, log in, and log out.
- Access control enforced with Pundit to handle role-based access control for `Librarian` and `Member`.
- Spec files for authentication tests.

---

## 2. 📚 Book Management
- [x] **As a Librarian**, I want to add a new book with details like title, author, genre, ISBN, and total copies.  
- [x] **As a Librarian**, I want to edit or delete book details.  
- [x] **As a User**, I want to search books by title, author, or genre.  

**Acceptance Criteria:**
- Only Librarians can create, update, or delete books.
- All users can read and search books by title, author, or genre.
- Each book includes: title, author, genre, ISBN, total_copies, and available_copies.
- Spec file for book tests.

---

## 3. 📖 Borrowing and Returning Books
- [x] **As a Member**, I want to borrow a book if copies are available and if it was not borrowed previously by me.  
- [x] **As a Member**, I want to return a book if it was borrowed by me.  
- [x] **As a Librarian**, I want to mark books as returned so that the catalog remains accurate.  

**Acceptance Criteria:**
- Only Members can create borrowings and a member cannot borrow the same book twice concurrently.
- Each borrowing records `borrowed_at` and `due_date` (2 weeks after).
- System decrements `available_copies` and increments it when returned.
- `returned_at` recorded when a book is returned.
- Spec file for borrowings tests.

---

## 4. Dashboard
- [x] **As a Librarian**, I want to view a dashboard with key metrics so that I can monitor the library's overall status.  
- [x] **As a Member**, I want to view my borrowed books and their due dates so that I can track my loans.  

**Acceptance Criteria:**
- Librarian dashboard shows:
  - Total books  
  - Total borrowed books  
  - Books due today  
  - Members with overdue books  
- Member dashboard shows:
  - Borrowed books with due dates and overdue status  
- Data returned as JSON for frontend consumption.
- Spec file for dashboard tests.

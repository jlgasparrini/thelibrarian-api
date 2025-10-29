# 📚 Backend User Stories

## 1. 👤 Authentication & Roles
- [x] **As a Member**, I want to register, log in, and log out.  
- [x] **As a Librarian**, I want to log in, and log out.  

**Acceptance Criteria:**
- Using Devise JWT users can sign up, log in, and log out.
- Access control enforced with Pundit to handle role-based access control for `Librarian` and `Member`.
- Spec files for authentication tests.

**Endpoints involved:**
| Method | Endpoint | Description | Access |
|--------|-----------|--------------|---------|
| `POST` | `/api/v1/auth/sign_up` | Register new Member | Public |
| `POST` | `/api/v1/auth/sign_in` | Log in and return JWT token | Public |
| `DELETE` | `/api/v1/auth/sign_out` | Log out and revoke JWT | Authenticated |
| `GET` | `/api/v1/auth/validate_token` | Verify token validity | Authenticated |
| `GET` | `/api/v1/users/me` | Get current user profile | Authenticated |

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

**Endpoints involved:**
| Method | Endpoint | Description | Access |
|--------|-----------|-------------|---------|
| `GET` | `/api/v1/books` | List all books (supports search, pagination, and sorting) | Member + Librarian |
| `GET` | `/api/v1/books/:id` | Show book details | Member + Librarian |
| `POST` | `/api/v1/books` | Create new book | Librarian only |
| `PUT` | `/api/v1/books/:id` | Update book details | Librarian only |
| `DELETE` | `/api/v1/books/:id` | Delete a book | Librarian only |

**Search parameters (query params):**
- `?title=`
- `?author=`
- `?genre=`
- `?page=`
- `?sort=`

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

**Endpoints involved:**
| Method | Endpoint | Description | Access |
|--------|-----------|-------------|---------|
| `GET` | `/api/v1/borrowings` | List all borrowings (filtered by user role) | Member + Librarian |
| `GET` | `/api/v1/borrowings/:id` | Show a single borrowing record | Member + Librarian |
| `POST` | `/api/v1/borrowings` | Create a new borrowing (if copies available) | Member only |
| `PUT` | `/api/v1/borrowings/:id/return` | Mark borrowing as returned | Librarian only |
| `GET` | `/api/v1/borrowings/overdue` | List overdue borrowings | Librarian only |

**Automatic behaviors:**
- `due_date` defaults to `borrowed_at + 14 days`.
- `available_copies` decrements on borrow and increments on return.

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

**Endpoints involved:**
| Method | Endpoint | Description | Access |
|--------|-----------|-------------|---------|
| `GET` | `/api/v1/dashboard` | Returns aggregated library statistics | Librarian only |
| `GET` | `/api/v1/dashboard` | Returns list of member’s active and overdue borrowings | Member only |


# 🧭 Development Roadmap — Library Management API (TDD)

This roadmap defines the sequence of development tasks to build the backend API for the Library Management System, following the user stories from [USER_STORIES.md](./USER_STORIES.md).
Each step is self-contained and test-driven: implement → test → refactor → commit.

---

## 🩵 Step 1 — Project Setup
- [x] Initialize a new Rails API project: `rails new thelibrarian-api --api`
- [x] Add required gems:
  - devise
  - devise-jwt
  - pundit
  - rspec-rails
  - factory_bot_rails
  - faker
  - rack-cors
- [x] Configure RSpec as default test framework.
- [x] Create `.env` for secret keys and JWT configuration.
- [x] Configure CORS for React frontend.
- [x] Create initial home endpoint (`GET /api/v1/health`) for smoke testing.
- [x] ✅ Run first RSpec test confirming `/health` returns 200 OK.

---

## 👤 Step 2 — Authentication & Roles
**Goal:** Implement Devise authentication and role-based access control.

- [ ] Generate `User` model with Devise.
- [ ] Add `role` column (enum: `member: 0`, `librarian: 1`).
- [ ] Configure **Devise JWT** for token-based auth.
- [ ] Implement Pundit for authorization policies.
- [ ] Create endpoints:
  - [ ] `POST /api/v1/auth/sign_up`
  - [ ] `POST /api/v1/auth/sign_in`
  - [ ] `DELETE /api/v1/auth/sign_out`
  - [ ] `GET /api/v1/users/me`
- [ ] Write RSpec tests for:
  - User registration
  - JWT authentication
  - Role enforcement (member vs librarian)
- [ ] ✅ Run tests → all authentication specs passing.

---

## 📚 Step 3 — Book Management
**Goal:** Allow Librarians to manage books, and Members to view/search them.

- [ ] Generate `Book` model with attributes:
  - title, author, genre, isbn, total_copies, available_copies
- [ ] Validate presence and uniqueness where needed.
- [ ] Create controller `BooksController`.
- [ ] Implement endpoints:
  - [ ] `GET /api/v1/books`
  - [ ] `GET /api/v1/books/:id`
  - [ ] `POST /api/v1/books`
  - [ ] `PUT /api/v1/books/:id`
  - [ ] `DELETE /api/v1/books/:id`
- [ ] Add search, and sorting (params: `title`, `author`, `genre`, `page`, `sort`).
- [ ] Apply Pundit policies:
  - Librarian → full CRUD
  - Member → read only
- [ ] Write RSpec request specs for all endpoints.
- [ ] ✅ Run tests → all book specs passing.

---

## 📖 Step 4 — Borrowing Flow
**Goal:** Allow Members to borrow and return books.

- [ ] Generate `Borrowing` model:
  - attributes: `user_id`, `book_id`, `borrowed_at`, `due_date`, `returned_at`
- [ ] Add validations:
  - borrowed_at, due_date presence
  - user must be Member
  - cannot borrow same book twice concurrently
- [ ] Implement automatic behaviors:
  - due_date defaults to borrowed_at + 14 days
  - available_copies decrement/increment on borrow/return
- [ ] Create controller `BorrowingsController`.
- [ ] Implement endpoints:
  - [ ] `GET /api/v1/borrowings`
  - [ ] `POST /api/v1/borrowings`
  - [ ] `PUT /api/v1/borrowings/:id/return`
  - [ ] `GET /api/v1/borrowings/overdue`
- [ ] Write RSpec tests for:
  - Borrowing creation (success/failure)
  - Returning flow
  - Overdue scope
- [ ] ✅ Run tests → all borrowing specs passing.

---

## 📊 Step 5 — Dashboard Endpoints
**Goal:** Expose aggregated data for both roles.

- [ ] Create `DashboardsController`.
- [ ] Implement endpoints:
  - [ ] `GET /api/v1/dashboard`
  - [ ] `GET /api/v1/dashboard`
- [ ] Librarian dashboard returns:
  - total_books
  - borrowed_books
  - books_due_today
  - members_with_overdue_books
- [ ] Member dashboard returns:
  - borrowed books list, due dates, overdue status
- [ ] Write RSpec tests validating JSON structure.
- [ ] ✅ Run tests → all dashboard specs passing.

---

## 🧪 Step 6 — Final QA & Refactor
- [ ] Review all models for missing indexes, constraints, and validations.
- [ ] Ensure Pundit policies are enforced in every controller.
- [ ] Add request specs for unauthorized/forbidden access.
- [ ] Seed data - Populate database with books and borrowings. Add demo users:
  - Librarian: `admin@library.com / password`
  - Member: `member@library.com / password`
- [ ] ✅ Final RSpec run → 100% passing.
- [ ] ✅ Project ready for frontend integration.

---

## 🧱 Step 7 — Enhancements & Polish

**Goal:** Add advanced, production-grade features that improve robustness and maintainability.

### Soft Delete
- Add `deleted_at` to Book, Borrowing, and optionally User models.
- Use `paranoia` gem or manual scope filtering.
- Update destroy actions to perform logical deletes.

### ActiveAdmin Integration
- Install and configure ActiveAdmin for internal maintenance.
- Restrict access to admin users.
- Display summary of books, members, and borrowings.

### Borrowing Lifecycle (State Machine)
- Use AASM to manage borrowing states:
  - requested → borrowed → returned → overdue
- Add RSpec specs to validate transitions and invalid state changes.

### Pagination
- Integrate `pagy` for paginated and sorted responses to increase scalability.
- Include metadata: `total`, `page`, `pages`, `per_page`.
- Apply to Books, Borrowings, and Dashboard endpoints.

### API Documentation
- Integrate Swagger (`rswag`) for auto-generated API docs.
- Add endpoint `/api-docs` for reviewers.

### Audit Logging
- Implemented activity logging for all key models (**User**, **Book**, **Borrowing**) using `audited` gem or a custom logging mechanism.
- Each create, update, or delete action is automatically tracked and viewable via **ActiveAdmin**.
- Enables librarians and administrators to review:
  - Who performed the change
  - When it happened
  - What fields were modified
- Complements the **Soft Delete** feature to provide full traceability and accountability.

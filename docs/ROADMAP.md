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

- [x] Generate `User` model with Devise.
- [x] Add `role` column (enum: `member: 0`, `librarian: 1`).
- [x] Configure **Devise JWT** for token-based auth.
- [x] Implement Pundit for authorization policies.
- [x] Create endpoints:
  - [x] `POST /api/v1/auth/sign_up`
  - [x] `POST /api/v1/auth/sign_in`
  - [x] `DELETE /api/v1/auth/sign_out`
  - [x] `GET /api/v1/users/me`
- [x] Write RSpec tests for:
  - [x] User registration
  - [x] JWT authentication
  - [x] Role enforcement (member vs librarian)
- [x] ✅ Run tests → all authentication specs passing (31 examples, 0 failures).

---

## 📚 Step 3 — Book Management
**Goal:** Allow Librarians to manage books, and Members to view/search them.

- [x] Generate `Book` model with attributes:
  - title, author, genre, isbn, total_copies, available_copies
- [x] Validate presence and uniqueness where needed.
- [x] Create controller `BooksController`.
- [x] Implement endpoints:
  - [x] `GET /api/v1/books`
  - [x] `GET /api/v1/books/:id`
  - [x] `POST /api/v1/books`
  - [x] `PUT /api/v1/books/:id`
  - [x] `DELETE /api/v1/books/:id`
- [x] Add search, and sorting (params: `query`, `genre`, `available`, `sort`).
- [x] Apply Pundit policies:
  - Librarian → full CRUD
  - Member → read only
- [x] Write RSpec request specs for all endpoints.
- [x] ✅ Run tests → all book specs passing (71 examples, 0 failures).

---

## 📖 Step 4 — Borrowing Flow
**Goal:** Allow Members to borrow and return books.

- [x] Generate `Borrowing` model:
  - attributes: `user_id`, `book_id`, `borrowed_at`, `due_date`, `returned_at`
- [x] Add validations:
  - borrowed_at, due_date presence
  - user must be Member
  - cannot borrow same book twice concurrently
  - book must be available
- [x] Implement automatic behaviors:
  - borrowed_at defaults to Time.current
  - due_date defaults to borrowed_at + 14 days
  - available_copies decrement/increment on borrow/return
- [x] Create controller `BorrowingsController`.
- [x] Implement endpoints:
  - [x] `GET /api/v1/borrowings` (with status filters: active, returned, overdue)
  - [x] `GET /api/v1/borrowings/:id`
  - [x] `POST /api/v1/borrowings`
  - [x] `PUT /api/v1/borrowings/:id` (return action)
  - [x] `GET /api/v1/borrowings/overdue`
- [x] Write RSpec tests for:
  - Borrowing creation (success/failure)
  - Returning flow
  - Overdue scope
  - Authorization (members vs librarians)
- [x] ✅ Run tests → all borrowing specs passing (112 examples, 0 failures).

---

## 📊 Step 5 — Dashboard Endpoints
**Goal:** Expose aggregated data for both roles.

- [x] Create `DashboardsController`.
- [x] Implement endpoints:
  - [x] `GET /api/v1/dashboard` (role-based response)
- [x] Librarian dashboard returns:
  - total_books, total_available_books
  - total_borrowed_books, books_due_today
  - overdue_books, total_members
  - members_with_overdue_books
  - recent_borrowings (last 10)
  - popular_books (top 10 by borrowings_count)
  - overdue_borrowings (top 10)
- [x] Member dashboard returns:
  - active_borrowings_count, overdue_borrowings_count
  - books_due_soon (within 3 days)
  - borrowed_books (with book details, due dates, overdue status)
  - borrowing_history (last 10 returned books)
- [x] Write RSpec tests validating JSON structure.
- [x] ✅ Run tests → all dashboard specs passing (137 examples, 0 failures).

---

## 🧪 Step 6 — Final QA
- [x] Review all models for missing indexes, constraints, and validations.
  - All models have proper validations
  - Comprehensive indexing (GIN trigram, composite, foreign keys)
  - Counter cache for performance
  - Pessimistic locking for race conditions
- [x] Ensure Pundit policies are enforced in every controller.
  - All 12 controller actions have `authorize` calls
  - Policies: BookPolicy, BorrowingPolicy, DashboardPolicy, UserPolicy
- [x] Add request specs for unauthorized/forbidden access.
  - All request specs test authentication and authorization
  - 74 request specs covering all scenarios
- [x] Seed data - Populate database with books and borrowings. Add demo users:
  - Librarian: `admin@library.com / password`
  - Member: `member@library.com / password`
  - Member: `john.doe@library.com / password`
  - Member: `jane.smith@library.com / password`
  - 25 books across 5 genres
  - 12 borrowings (5 active, 2 overdue, 5 returned)
- [x] Create comprehensive API documentation.
- [x] Setup CI/CD with GitHub Actions, setting up deployment to Render.com.
- [x] ✅ Final RSpec run → 100% passing (137 examples, 0 failures).

---

## 🔧 Step 7 — Code Refactoring & Architecture Improvements
**Goal:** Improve code quality, maintainability, and scalability through architectural patterns.

- [x] **Serializers** - Extract JSON formatting logic
  - Created `BookSerializer` with multiple presentation methods (minimal, with_isbn, popular)
  - Created `BorrowingSerializer` with context-specific methods (with_relations, detailed, dashboard, history)
  - Updated `UserSerializer` with minimal method for nested responses
  - Eliminated ~60 lines of repeated `.as_json()` calls
  
- [x] **Service Objects** - Extract complex business logic
  - Created `DashboardService` for dashboard data aggregation
  - Reduced `DashboardsController` from 111 lines to 15 lines (86% reduction)
  - Improved testability and separation of concerns
  
- [x] **Concerns** - Reusable controller modules
  - Created `JsonResponse` concern for consistent API responses
  - Created `JwtAuthentication` concern for JWT token handling
  - DRY principle applied across controllers
  
- [x] **Constants** - Centralized configuration
  - Created `AppConstants` initializer
  - Extracted magic numbers (pagination, borrowing period, dashboard limits)
  - Single source of truth for configuration values
  
- [x] **Scopes** - Reusable query logic
  - Added `sorted_by` scope to Book model
  - Added `due_today` and `due_soon` scopes to Borrowing model
  - Cleaner controller code with chainable queries
  
- [x] **CI/CD Improvements**
  - Fixed JWT_SECRET_KEY configuration for test environment
  - All 137 tests passing in CI
  
- [x] ✅ All refactoring complete and code quality improved → 137 examples, 0 failures.
- [x] ✅ Ready for production deployment and frontend integration.


---

## 🧱 Step 8 — Enhancements

**Goal:** Add advanced, production-grade features.

### Soft Delete (paranoia gem) ✅
- [x] Add `deleted_at` to Book, Borrowing, and User models
- [x] Configure `acts_as_paranoid` in all models
- [x] Soft delete works automatically with destroy actions
- [x] Add specs for soft delete behavior
- [x] Add custom error message for deleted accounts
- [x] ✅ All tests passing → 179 examples, 0 failures

### Audit Logging (audited gem) ✅
- [x] Install and configure Audited gem
- [x] Enable auditing on User, Book, and Borrowing models
- [x] Add specs for audit trail
- [x] Maintain version history for all changes
- [x] ✅ All tests passing → 202 examples, 0 failures

### API Documentation (rswag gem) ✅
- [x] Install and configure Rswag gem
- [x] Create swagger_helper with API metadata
- [x] Add integration specs for Books and Auth endpoints
- [x] Define schemas for User, Book, Borrowing, and Error responses
- [x] Generate Swagger documentation and mount UI at `/api-docs` endpoint
- [x] ✅ All tests passing → 219 examples, 0 failures

### Code Coverage (simplecov gem)
- [x] Install and configure SimpleCov gem
- [x] Add specs for all models, controllers, and services
- [x] Generate code coverage report and mount UI at `/coverage` endpoint
- [x] ✅ All tests passing → 219 examples, 0 failures

---

## Technical Debt (or desired features) 

### Borrowing Lifecycle (AASM gem)
- [ ] Configure AASM state machine in Borrowing model
- [ ] Define states: requested → borrowed → returned → overdue
- [ ] Add transition validations and callbacks
- [ ] Update controller actions to use state transitions
- [ ] Add RSpec specs for state machine behavior

### Support multiple book instances (multiple copies of the same book)
- [ ] Add BookCopy model and connect it to Book and Borrowing models.
- [ ] Update Borrowing and Book references to use BookCopy model.
- [ ] Update specs to handle BookCopy instance.

## Additional Ideas
- [ ] Super Admin Dashboard (like ActiveAdmin).
- [ ] Rate limiting (rack-attack)
- [ ] Background jobs (Sidekiq) for notifications like emails notifications for overdue borrowings.
- [ ] Search optimization (Elasticsearch/pg_search).
- [ ] Webhooks for external integrations.
- [ ] Tickets (for support).

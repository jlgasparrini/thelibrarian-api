# 📚 Library Management API

A **production-ready Ruby on Rails RESTful API** for library management, featuring JWT authentication, role-based authorization, book management, borrowing workflows, and analytics dashboards — all built following **test-driven development (TDD)** principles.

[![Tests](https://img.shields.io/badge/tests-219%20passing-success)]()
[![Coverage](https://img.shields.io/badge/coverage-93.6%25-success)]()
[![Ruby](https://img.shields.io/badge/ruby-3.4.7-red)]()
[![Rails](https://img.shields.io/badge/rails-8.0-red)]()

---

## 🎯 Overview

This API supports two user roles:
- **Librarians** - Manage books, track borrowings, monitor library activity
- **Members** - Browse books, borrow/return items, track due dates

Built with clean architecture, comprehensive test coverage, and production-ready deployment configuration.

---

## 📚 Documentation

- 📘 [User Stories](./docs/USER_STORIES.md) - Functional requirements and API endpoints
- 🧱 [Development Roadmap](./docs/ROADMAP.md) - TDD development guide and implementation steps
- 📖 [API Documentation](./docs/API_DOCUMENTATION.md) - Complete endpoint reference with examples
- 🐳 [Docker Setup](./docs/DOCKER.md) - Local development with Docker
- 🚀 [Deployment Guide](./docs/DEPLOYMENT.md) - Production deployment instructions
- ✅ [Production Checklist](./docs/PRODUCTION_CHECKLIST.md) - Pre-deployment verification

---

## ⚙️ Tech Stack

| Category | Technology |
|-----------|-------------|
| **Language** | Ruby 3.4.7 |
| **Framework** | Ruby on Rails 8.0 (API mode) |
| **Database** | PostgreSQL 14+ |
| **Authentication** | Devise + Devise-JWT |
| **Authorization** | Pundit |
| **Testing** | RSpec + FactoryBot + Faker + SimpleCov |
| **Pagination** | Pagy |
| **Soft Delete** | Paranoia |
| **Audit Logging** | Audited |
| **API Docs** | Rswag (Swagger/OpenAPI) |
| **CI/CD** | GitHub Actions |
| **Deployment** | Docker + Render.com |
| **Code Quality** | RuboCop + Brakeman |

---

## 🚀 Quick Start

### Option 1: Local Setup

```bash
# 1. Clone the repository
git clone https://github.com/jlgasparrini/thelibrarian-api.git
cd thelibrarian-api

# 2. Install dependencies
bundle install

# 3. Create .env file
cp .env.example .env
# Edit .env and set JWT_SECRET_KEY

# 4. Setup database
rails db:create db:migrate db:seed

# 5. Run tests
bundle exec rspec

# 6. Start server
rails server
```

### Option 2: Docker Setup

```bash
# 1. Clone and setup
git clone https://github.com/jlgasparrini/thelibrarian-api.git
cd thelibrarian-api
cp .env.example .env

# 2. Build and run
docker compose up

# 3. Setup database (in another terminal)
docker compose exec web rails db:prepare db:seed

# 4. Run tests
docker compose exec web bundle exec rspec
```

### 🔑 Demo Credentials

After running `db:seed`:
- **Librarian:** `admin@library.com` / `password`
- **Member:** `member@library.com` / `password`
- **Member:** `john.doe@library.com` / `password`
- **Member:** `jane.smith@library.com` / `password`

### 🧪 Verify Installation

```bash
# Health check
curl http://localhost:3000/api/v1/health

# Should return: {"status":"ok"}
```

---

## 🎯 Features

### ✅ Implemented

| Feature | Description |
|---------|-------------|
| 👤 **Authentication** | JWT-based auth with Devise (sign up, sign in, sign out) |
| 🔐 **Authorization** | Role-based access control with Pundit (Librarian/Member) |
| 📚 **Book Management** | Full CRUD for librarians, read-only for members |
| 🔍 **Search & Filter** | Search by title/author/ISBN, filter by genre/availability |
| 📖 **Borrowing System** | Borrow/return books with automatic due dates (14 days) |
| 📊 **Dashboards** | Role-specific analytics and borrowing insights |
| 📄 **Pagination** | Pagy-powered pagination on all list endpoints |
| 🗑️ **Soft Delete** | Paranoia gem for logical deletion with restore capability |
| 📝 **Audit Logging** | Complete audit trail of all changes with Audited gem |
| 📚 **API Documentation** | Interactive Swagger/OpenAPI docs at `/api-docs` |
| 🐳 **Docker Support** | Full Docker Compose setup for local development |
| 🚀 **CI/CD** | GitHub Actions for automated testing |

### 🔮 Planned Features

- **State Machine** (aasm) - Borrowing lifecycle management (requested → borrowed → returned → overdue)
- **Book Instances** - Track individual physical copies with barcodes and conditions
- **Rate Limiting** - API throttling with rack-attack
- **Background Jobs** - Email notifications for overdue books with Sidekiq
- **Search Optimization** - Full-text search with Elasticsearch or pg_search

See [ROADMAP.md](./docs/ROADMAP.md) for implementation details.

---

## 🧱 Project Structure
```
app/
 ├── controllers/
 │    ├── concerns/              # Reusable controller modules
 │    │    ├── json_response.rb
 │    │    └── jwt_authentication.rb
 │    └── api/v1/
 │         ├── auth/             # Authentication endpoints
 │         ├── books_controller.rb
 │         ├── borrowings_controller.rb
 │         ├── dashboards_controller.rb
 │         ├── health_controller.rb
 │         └── users_controller.rb
 ├── models/
 │    ├── user.rb
 │    ├── book.rb
 │    ├── borrowing.rb
 │    └── jwt_denylist.rb
 ├── policies/                   # Pundit authorization
 │    ├── application_policy.rb
 │    ├── book_policy.rb
 │    ├── borrowing_policy.rb
 │    ├── dashboard_policy.rb
 │    └── user_policy.rb
 ├── serializers/                # JSON response formatting
 │    ├── book_serializer.rb
 │    ├── borrowing_serializer.rb
 │    └── user_serializer.rb
 └── services/                   # Business logic
      └── dashboard_service.rb

config/
 ├── initializers/
 │    └── app_constants.rb       # Application constants
 └── routes.rb

spec/
 ├── models/
 ├── policies/
 └── requests/
```

## 🧪 Testing

### Test Coverage
- **219 examples, 0 failures**
- **93.6% code coverage**
- Model specs (validations, associations, scopes, audit logging)
- Request specs (endpoints, authentication, authorization)
- Policy specs (role-based access control)
- Integration specs (API documentation with Rswag)

### Run Tests
```bash
# All tests (with coverage report)
bundle exec rspec

# Specific file
bundle exec rspec spec/models/book_spec.rb

# With documentation format
bundle exec rspec --format documentation

# View coverage report
open coverage/index.html
```

**Coverage Report:**
- Automatically generated after running tests
- Located at `coverage/index.html`
- Current coverage: **93.6%** (380/406 lines)
- Grouped by: Models, Controllers, Policies, Serializers

## 🏗️ Architecture & Design Patterns

### Clean Architecture
- **Controllers** - Thin, handle HTTP concerns only
- **Services** - Complex business logic (e.g., DashboardService)
- **Serializers** - JSON response formatting
- **Policies** - Authorization rules
- **Concerns** - Reusable modules (JsonResponse, JwtAuthentication)

### Key Patterns
- **Service Objects** - Encapsulate complex operations
- **Serializers** - Consistent API responses
- **Scopes** - Reusable query logic
- **Constants** - Centralized configuration
- **Policy Objects** - Authorization logic separation


## 📡 API Examples

### Authentication
```bash
# Sign up
curl -X POST http://localhost:3000/api/v1/auth/sign_up \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password","role":"member"}'

# Sign in
curl -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"email":"member@library.com","password":"password"}'

# Returns JWT token in Authorization header
```

### Books
```bash
# List books (with filters)
curl http://localhost:3000/api/v1/books?query=ruby&genre=Programming&available=true

# Get book details
curl http://localhost:3000/api/v1/books/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Create book (librarian only)
curl -X POST http://localhost:3000/api/v1/books \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"book":{"title":"Clean Code","author":"Robert Martin","isbn":"978-0132350884","genre":"Programming","total_copies":5}}'
```

### Borrowings
```bash
# Borrow a book
curl -X POST http://localhost:3000/api/v1/borrowings \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"borrowing":{"book_id":1}}'

# Return a book
curl -X PUT http://localhost:3000/api/v1/borrowings/1 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"action_type":"return"}'

# List overdue borrowings (librarian only)
curl http://localhost:3000/api/v1/borrowings/overdue \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Dashboard
```bash
# Get role-specific dashboard
curl http://localhost:3000/api/v1/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

See [API_DOCUMENTATION.md](./docs/API_DOCUMENTATION.md) for complete endpoint reference.

## 🚀 Deployment

### Docker
See [DOCKER.md](./docs/DOCKER.md) for complete Docker setup instructions.

### Production (Render.com)
See [DEPLOYMENT.md](./docs/DEPLOYMENT.md) and [QUICK_DEPLOY.md](./docs/QUICK_DEPLOY.md) for deployment guides.

### Environment Variables
Required for production:
- `RAILS_MASTER_KEY` - Rails credentials encryption key
- `JWT_SECRET_KEY` - JWT token signing key
- `DATABASE_URL` - PostgreSQL connection string (auto-set by Render)

---

## 📈 Code Quality

### Metrics
- **137 RSpec tests** - 100% passing
- **Clean Architecture** - Services, Serializers, Concerns
- **DRY Principles** - Reusable components
- **Security** - Brakeman scans, JWT authentication
- **Performance** - Database indexing, counter caches, pessimistic locking

### Recent Improvements
- ✅ Extracted serializers for consistent JSON formatting
- ✅ Created service objects for complex business logic
- ✅ Added concerns for reusable controller functionality
- ✅ Centralized constants and configuration
- ✅ Added model scopes for cleaner queries
- ✅ Reduced DashboardsController from 111 to 15 lines (86% reduction)

See commit history for detailed refactoring work.

---

## 🏁 Project Status

### ✅ Completed
- Core API functionality (auth, books, borrowings, dashboards)
- Comprehensive test suite (137 examples)
- Docker containerization
- CI/CD pipeline with GitHub Actions
- Production deployment configuration
- Code refactoring and architecture improvements
- Complete documentation

### 🔮 Future Enhancements
See [ROADMAP.md](./docs/ROADMAP.md) Step 8 for planned features:
- Soft delete with Paranoia
- ActiveAdmin panel
- AASM state machine
- Swagger/OpenAPI docs
- Audit logging

---

## 👤 Author

**Leonel Gasparrini**  
Ruby on Rails Developer  
🇦🇷 Argentina

- [GitHub](https://github.com/jlgasparrini)
- [LinkedIn](https://linkedin.com/in/jlgasparrini/)

---

## 📄 License

This project is available for portfolio and educational purposes.

---

## 🙏 Acknowledgments

Built with:
- Test-Driven Development (TDD) methodology
- Clean Architecture principles
- RESTful API best practices
- Ruby on Rails conventions
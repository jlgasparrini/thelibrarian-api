# 📚 Library Management API

This project is a **Ruby on Rails RESTful API**. It implements a complete **Library Management System**, featuring authentication, role-based access, book management, borrowing flows, and dashboards — all built following **test-driven development (TDD)** principles.

---

## 🧩 Informal User Story

The system is designed to support two main roles within a library environment: **Librarians** and **Members**.  
Librarians need a way to efficiently manage books, track borrowings, and monitor library activity.  
Members should be able to register, browse available books, borrow and return them, and keep track of their due dates.  

This API allows both **Librarians** and **Members** to log in, interact with books, and access personalized dashboards.

---

## 🧭 Project Documentation

- 📘 [User Stories](./USER_STORIES.md)  
  Functional requirements and API endpoints.

- 🧱 [API Roadmap](./ROADMAP.md)  
  Step-by-step TDD development guide including models, controllers, specs, and enhancements.

---

## ⚙️ Tech Stack

| Category | Technology |
|-----------|-------------|
| Language | Ruby 3.x |
| Framework | Ruby on Rails 8.x |
| Database | PostgreSQL 14.x |
| Authentication | Devise JWT |
| Authorization | Pundit |
| Testing | RSpec + FactoryBot + Faker |
| State Machine | AASM |
| Pagination | Pagy |
| Soft Delete | Paranoia |
| Documentation | Rswag (Swagger UI) |
| Admin Panel | ActiveAdmin |
| Audit Logging | Audited |

---

## 🚀 Setup Instructions

### 1️⃣ Clone the repository
```bash
git clone https://github.com/jlgasparrini/thelibrarian-api.git
cd thelibrarian-api
```

### 2️⃣ Install dependencies
```bash
bundle install
```

### 3️⃣ Create a `.env` file with the following keys:
```bash
JWT_SECRET_KEY=your_secret_key
```

### 4️⃣ Setup the database
```bash
rails db:create db:migrate db:seed
```
Seeds include:
- Librarian: admin@library.com / password
- Member: member@library.com / password

### 5️⃣ Run the test suite
```bash
bundle exec rspec
```

### 6️⃣ Start the server
```bash
rails server
```

### 7️⃣ Access the API
Open your browser and navigate to `http://localhost:3000` to access the API.

### 8️⃣ Access Documentation & Admin Panel

**API Documentation (Swagger UI)**
- URL: `http://localhost:3000/api-docs`
- Interactive API documentation with all endpoints

**Admin Panel (ActiveAdmin)**
- URL: `http://localhost:3000/admin`
- Login with librarian credentials: `admin@library.com` / `password`
- Manage users, books, and borrowings through the web interface

---

## 🧪 API Overview

| **Feature** | **Description** |
|--------------|----------------|
| 👤 **Authentication** | Handles user registration, login, logout, and token validation using **Devise JWT**. |
| 🧑‍💼 **Roles & Authorization** | Supports two roles — `Librarian` and `Member`. Authorization enforced with **Pundit** policies. |
| 📚 **Books Management** | Librarians can create, update, or delete books. Members can search, filter, and view available books. |
| 📖 **Borrowings** | Members can borrow and return books. Librarians can manage borrowing records and mark returns. |
| 📊 **Dashboard** | Returns contextual data based on user role — library stats for librarians, borrowing info for members. |
| 🗂️ **Admin Panel** | **ActiveAdmin** interface for librarians to manage users, books, and borrowings. |
| 🧾 **API Documentation** | Auto-generated **Swagger (Rswag)** documentation accessible via `/api-docs`. |
| 🧱 **Enhancements** | Includes soft delete, pagination, AASM state machine, and audit logging. |
| 🔎 **Audit Logging** | Activity logging for all key models (User, Book, Borrowing) using `audited` gem or a custom logging mechanism. |

---

## 🧱 Project Structure
```
app/
 ├── controllers/
 │    ├── api/
 │    │    └── v1/
 │    │         ├── auth/
 │    │         ├── books_controller.rb
 │    │         ├── borrowings_controller.rb
 │    │         └── dashboards_controller.rb
 ├── models/
 │    ├── user.rb
 │    ├── book.rb
 │    └── borrowing.rb
 ├── policies/

spec/
 ├── requests/
 ├── models/
 └── policies/
```

## 🧪 Testing Approach (TDD)

Each step in the API Roadmap includes:

- Model specs (validations, associations, and behaviors)
- Request specs (endpoint responses and access control)
- Policy specs (authorization rules)
- State machine tests for borrowings

Run tests continuously after each implementation phase.

## 🧱 Enhancements & Advanced Features

- ✅ Soft Delete for safe record management (deleted_at timestamps)
- ✅ Borrowing Lifecycle managed with AASM state machine
- ✅ Pagination & Sorting via Pagy
- ✅ Auto-Generated Swagger API Documentation with Rswag
- ✅ ActiveAdmin integration for librarian management
- ✅ Audit Logging for all actions


## 🧾 Example Requests

### 🔐 Login
```http
POST /api/v1/auth/sign_in
```
```json
{
  "email": "member@library.com",
  "password": "password"
}
```

### 📚 List Books
```http
GET /api/v1/books?page=1&genre=fiction
```

### 📖 Borrow a Book
```http
POST /api/v1/borrowings
```
```json
{
  "book_id": 1
}
```

### 📊 Dashboard
```http
GET /api/v1/dashboard
```
Returns JSON depending on current_user.role

## 🏁 Notes for Reviewers

- The project was built using TDD from start to finish.
- Each user story is fully testable and linked to a roadmap step.
- Code follows RESTful conventions, role-based access control, and clean architecture.
- Focused on clarity, maintainability, and correctness rather than over-engineering.

## 👤 Author

Leonel Gasparrini
Ruby on Rails Developer
🇦🇷 [GitHub](https://github.com/jlgasparrini) · [LinkedIn](https://linkedin.com/in/jlgasparrini/)
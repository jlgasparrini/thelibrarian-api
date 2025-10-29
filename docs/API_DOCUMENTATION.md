# 📖 API Documentation

## Base URL
```
http://localhost:3000/api/v1
```

## Authentication

All endpoints (except health check) require authentication using JWT tokens.

### Headers
```
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

---

## 🔐 Authentication Endpoints

### Sign Up
```http
POST /api/v1/auth/sign_up
```

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password",
    "password_confirmation": "password",
    "role": "member"  // optional: "member" (default) or "librarian"
  }
}
```

**Response (201):**
```json
{
  "message": "Signed up successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": "member"
  }
}
```

### Sign In
```http
POST /api/v1/auth/sign_in
```

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}
```

**Response (200):**
```json
{
  "message": "Logged in successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": "member"
  }
}
```
**Headers:** Returns JWT token in `Authorization` header

### Sign Out
```http
DELETE /api/v1/auth/sign_out
```

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

### Get Current User
```http
GET /api/v1/users/me
```

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "role": "member",
    "created_at": "2025-10-29T00:00:00.000Z"
  }
}
```

---

## 📚 Books Endpoints

### List Books
```http
GET /api/v1/books
```

**Query Parameters:**
- `query` - Search by title, author, or ISBN
- `genre` - Filter by genre
- `available` - Filter available books (`true`/`false`)
- `sort` - Sort by `title`, `author`, or `created_at`
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 25)

**Response (200):**
```json
{
  "books": [
    {
      "id": 1,
      "title": "Clean Code",
      "author": "Robert C. Martin",
      "genre": "Programming",
      "isbn": "978-0132350884",
      "total_copies": 5,
      "available_copies": 3,
      "borrowings_count": 2,
      "created_at": "2025-10-29T00:00:00.000Z",
      "updated_at": "2025-10-29T00:00:00.000Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 25,
    "per_page": 25
  }
}
```

### Get Book
```http
GET /api/v1/books/:id
```

**Response (200):**
```json
{
  "book": {
    "id": 1,
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "genre": "Programming",
    "isbn": "978-0132350884",
    "total_copies": 5,
    "available_copies": 3,
    "borrowings_count": 2
  }
}
```

### Create Book (Librarian Only)
```http
POST /api/v1/books
```

**Request Body:**
```json
{
  "book": {
    "title": "New Book",
    "author": "Author Name",
    "genre": "Fiction",
    "isbn": "978-1234567890",
    "total_copies": 5,
    "available_copies": 5
  }
}
```

**Response (201):**
```json
{
  "book": { /* book object */ },
  "message": "Book created successfully"
}
```

### Update Book (Librarian Only)
```http
PUT /api/v1/books/:id
```

**Request Body:**
```json
{
  "book": {
    "title": "Updated Title",
    "total_copies": 10
  }
}
```

**Response (200):**
```json
{
  "book": { /* updated book object */ },
  "message": "Book updated successfully"
}
```

### Delete Book (Librarian Only)
```http
DELETE /api/v1/books/:id
```

**Response (200):**
```json
{
  "message": "Book deleted successfully"
}
```

---

## 📖 Borrowings Endpoints

### List Borrowings
```http
GET /api/v1/borrowings
```

**Query Parameters:**
- `status` - Filter by status: `active`, `returned`, or `overdue`
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 25)

**Response (200):**
```json
{
  "borrowings": [
    {
      "id": 1,
      "borrowed_at": "2025-10-24T00:00:00.000Z",
      "due_date": "2025-11-07T00:00:00.000Z",
      "returned_at": null,
      "book": {
        "id": 1,
        "title": "Clean Code",
        "author": "Robert C. Martin"
      },
      "user": {
        "id": 2,
        "email": "member@library.com"
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 7,
    "per_page": 25
  }
}
```

**Note:** Members see only their own borrowings. Librarians see all borrowings.

### Get Borrowing
```http
GET /api/v1/borrowings/:id
```

**Response (200):**
```json
{
  "borrowing": {
    "id": 1,
    "borrowed_at": "2025-10-24T00:00:00.000Z",
    "due_date": "2025-11-07T00:00:00.000Z",
    "returned_at": null,
    "book": {
      "id": 1,
      "title": "Clean Code",
      "author": "Robert C. Martin",
      "isbn": "978-0132350884"
    },
    "user": {
      "id": 2,
      "email": "member@library.com"
    }
  }
}
```

### Borrow Book (Member Only)
```http
POST /api/v1/borrowings
```

**Request Body:**
```json
{
  "borrowing": {
    "book_id": 1
  }
}
```

**Response (201):**
```json
{
  "borrowing": { /* borrowing object */ },
  "message": "Book borrowed successfully"
}
```

**Automatic Behaviors:**
- `borrowed_at` is set to current time
- `due_date` is set to 14 days from now
- Book's `available_copies` is decremented
- Validates book availability
- Prevents borrowing same book twice concurrently

### Return Book
```http
PUT /api/v1/borrowings/:id
```

**Request Body:**
```json
{
  "action_type": "return"
}
```

**Response (200):**
```json
{
  "borrowing": { /* updated borrowing object */ },
  "message": "Book returned successfully"
}
```

**Automatic Behaviors:**
- `returned_at` is set to current time
- Book's `available_copies` is incremented

### List Overdue Borrowings
```http
GET /api/v1/borrowings/overdue
```

**Query Parameters:**
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 25)

**Response (200):**
```json
{
  "borrowings": [ /* array of overdue borrowings */ ],
  "pagination": { /* pagination metadata */ }
}
```

---

## 📊 Dashboard Endpoint

### Get Dashboard
```http
GET /api/v1/dashboard
```

**Librarian Response (200):**
```json
{
  "dashboard": {
    "total_books": 25,
    "total_available_books": 18,
    "total_borrowed_books": 7,
    "books_due_today": 1,
    "overdue_books": 2,
    "total_members": 3,
    "members_with_overdue_books": 2,
    "recent_borrowings": [
      {
        "id": 1,
        "borrowed_at": "2025-10-24T00:00:00.000Z",
        "due_date": "2025-11-07T00:00:00.000Z",
        "returned_at": null,
        "book": {
          "id": 1,
          "title": "Clean Code",
          "author": "Robert C. Martin"
        },
        "user": {
          "id": 2,
          "email": "member@library.com"
        }
      }
    ],
    "popular_books": [
      {
        "id": 1,
        "title": "Clean Code",
        "author": "Robert C. Martin",
        "borrowings_count": 10,
        "available_copies": 3
      }
    ],
    "overdue_borrowings": [ /* array of overdue borrowings */ ]
  }
}
```

**Member Response (200):**
```json
{
  "dashboard": {
    "active_borrowings_count": 3,
    "overdue_borrowings_count": 1,
    "books_due_soon": 1,
    "borrowed_books": [
      {
        "id": 1,
        "borrowed_at": "2025-10-24T00:00:00.000Z",
        "due_date": "2025-11-07T00:00:00.000Z",
        "overdue?": false,
        "book": {
          "id": 1,
          "title": "Clean Code",
          "author": "Robert C. Martin",
          "isbn": "978-0132350884"
        }
      }
    ],
    "borrowing_history": [
      {
        "id": 5,
        "borrowed_at": "2025-09-29T00:00:00.000Z",
        "due_date": "2025-10-13T00:00:00.000Z",
        "returned_at": "2025-10-10T00:00:00.000Z",
        "book": {
          "id": 3,
          "title": "Refactoring",
          "author": "Martin Fowler"
        }
      }
    ]
  }
}
```

---

## 🏥 Health Check

### Health Check
```http
GET /api/v1/health
```

**Response (200):**
```json
{
  "status": "ok",
  "timestamp": "2025-10-29T00:00:00.000Z"
}
```

---

## 🚫 Error Responses

### 401 Unauthorized
```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

### 403 Forbidden
```json
{
  "error": "You are not authorized to perform this action"
}
```

### 404 Not Found
```json
{
  "error": "Record not found"
}
```

### 422 Unprocessable Entity
```json
{
  "errors": [
    "Title can't be blank",
    "ISBN has already been taken"
  ]
}
```

---

## 🔑 Demo Credentials

```
Librarian:
  Email: admin@library.com
  Password: password

Members:
  Email: member@library.com
  Password: password
  
  Email: john.doe@library.com
  Password: password
  
  Email: jane.smith@library.com
  Password: password
```

---

## 📝 Notes

- All timestamps are in ISO 8601 format (UTC)
- Pagination is available on list endpoints
- JWT tokens expire after 24 hours
- Books have a 14-day borrowing period
- Race conditions are prevented with database-level locking
- All endpoints use JSON format

# 📋 API Quick Reference - Student Absence System

**Base URL:** `http://localhost:3000/api`

## 🔐 Authentication Header
```javascript
headers: {
  'Authorization': 'Bearer YOUR_TOKEN_HERE',
  'Content-Type': 'application/json'
}
```

---

## 🚀 QUICK START

### 1. Login
```javascript
POST /api/auth/login
Body: { "email": "manager@school.com", "password": "password123" }
// Returns: { token, user }
```

### 2. Get Current User
```javascript
GET /api/auth/me
// Returns: { user }
```

---

## 🧪 TEST CREDENTIALS

```
Manager:      manager@school.com      / password123
Teacher 1:    teacher1@school.com     / password123
Teacher 2:    teacher2@school.com     / password123
Receptionist: receptionist@school.com / password123
```

See full reference in the file for all endpoints, workflows, and Socket.IO events.

# API Testing Guide - Student Absence System

Backend running on: **http://localhost:3000**

## Prerequisites

```bash
# Install curl (usually pre-installed on Linux)
# Or use Postman, Insomnia, or any API testing tool
```

## Environment Variables

```bash
export API_BASE="http://localhost:3000/api"
```

---

## 1. Authentication Flow

### 1.1 Register a Manager

```bash
curl -X POST $API_BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin Manager",
    "email": "manager@school.com",
    "password": "manager123",
    "role": "manager"
  }'
```

**Expected Response:**
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Admin Manager",
      "email": "manager@school.com",
      "role": "manager",
      "isActive": true
    }
  }
}
```

**Save the token:**
```bash
export MANAGER_TOKEN="<token-from-response>"
```

### 1.2 Register a Teacher

```bash
curl -X POST $API_BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Dr. Emily Brown",
    "email": "emily.teacher@school.com",
    "password": "teacher123",
    "role": "teacher"
  }'
```

**Save the token:**
```bash
export TEACHER_TOKEN="<token-from-response>"
export TEACHER_ID="<user-id-from-response>"
```

### 1.3 Register a Receptionist

```bash
curl -X POST $API_BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sarah Johnson",
    "email": "sarah.receptionist@school.com",
    "password": "receptionist123",
    "role": "receptionist"
  }'
```

**Save the token:**
```bash
export RECEPTIONIST_TOKEN="<token-from-response>"
export RECEPTIONIST_ID="<user-id-from-response>"
```

### 1.4 Login (Existing User)

```bash
curl -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "manager@school.com",
    "password": "manager123"
  }'
```

---

## 2. Student Management (Manager Only)

### 2.1 Create Student

```bash
curl -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentCode": "STU001",
    "nama": "Ahmad Abdullah",
    "enrollmentDate": "2024-09-01"
  }'
```

**Save student ID:**
```bash
export STUDENT_ID="<student-id-from-response>"
```

### 2.2 Create More Students

```bash
# Student 2
curl -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentCode": "STU002",
    "nama": "Fatima Hassan",
    "enrollmentDate": "2024-09-01"
  }'

# Student 3
curl -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentCode": "STU003",
    "nama": "Mohammed Ali",
    "enrollmentDate": "2024-09-01"
  }'
```

### 2.3 Get All Students (with pagination)

```bash
curl -X GET "$API_BASE/students?page=1&limit=10" \
  -H "Authorization: Bearer $MANAGER_TOKEN"
```

### 2.4 Get Student by ID

```bash
curl -X GET $API_BASE/students/$STUDENT_ID \
  -H "Authorization: Bearer $MANAGER_TOKEN"
```

### 2.5 Update Student

```bash
curl -X PUT $API_BASE/students/$STUDENT_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "nama": "Ahmad Abdullah Updated",
    "isActive": true
  }'
```

---

## 3. Class Management (Manager Only)

### 3.1 Create Class

```bash
curl -X POST $API_BASE/classes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "name": "Mathematics 101",
    "description": "Basic mathematics course for first year",
    "teacher": "'$TEACHER_ID'",
    "capacity": 30,
    "startDate": "2024-09-01"
  }'
```

**Save class ID:**
```bash
export CLASS_ID="<class-id-from-response>"
```

### 3.2 Add Student to Class

```bash
curl -X POST $API_BASE/classes/$CLASS_ID/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentId": "'$STUDENT_ID'"
  }'
```

### 3.3 Get Classes by Teacher

```bash
curl -X GET $API_BASE/classes/teacher/$TEACHER_ID \
  -H "Authorization: Bearer $TEACHER_TOKEN"
```

### 3.4 Get Students in Class

```bash
curl -X GET $API_BASE/students/class/$CLASS_ID \
  -H "Authorization: Bearer $TEACHER_TOKEN"
```

### 3.5 Remove Student from Class

```bash
curl -X DELETE $API_BASE/classes/$CLASS_ID/students/$STUDENT_ID \
  -H "Authorization: Bearer $MANAGER_TOKEN"
```

---

## 4. Notification Workflow

### 4.1 Receptionist Sends Request to Teacher

```bash
curl -X POST $API_BASE/notifications/request \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" \
  -d '{
    "studentId": "'$STUDENT_ID'",
    "message": "Please verify if Ahmad Abdullah is present in class"
  }'
```

**Expected Response:**
```json
{
  "status": "success",
  "data": {
    "notification": {
      "_id": "notification_id",
      "from": "receptionist_id",
      "to": "teacher_id",
      "student": "student_id",
      "class": "class_id",
      "type": "request",
      "status": "pending",
      "message": "Please verify if Ahmad Abdullah is present in class",
      "isRead": false,
      "requestDate": "2025-01-15T10:30:00.000Z"
    }
  }
}
```

**Save notification ID:**
```bash
export NOTIFICATION_ID="<notification-id-from-response>"
```

### 4.2 Teacher Gets Notifications

```bash
curl -X GET $API_BASE/notifications \
  -H "Authorization: Bearer $TEACHER_TOKEN"
```

### 4.3 Teacher Responds to Request

```bash
curl -X PUT $API_BASE/notifications/$NOTIFICATION_ID/respond \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -d '{
    "status": "present",
    "responseMessage": "Yes, Ahmad is present in my class"
  }'
```

**Status options:** `present`, `absent`, `approved`, `rejected`

### 4.4 Receptionist Checks for Response

```bash
curl -X GET $API_BASE/notifications \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN"
```

### 4.5 Mark Notification as Read

```bash
curl -X PUT $API_BASE/notifications/$NOTIFICATION_ID/read \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN"
```

### 4.6 Get Unread Count

```bash
curl -X GET $API_BASE/notifications/unread/count \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN"
```

### 4.7 Teacher Sends Message to Receptionist

```bash
curl -X POST $API_BASE/notifications/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -d '{
    "receptionistId": "'$RECEPTIONIST_ID'",
    "studentId": "'$STUDENT_ID'",
    "message": "Please send Ahmad to the principal office"
  }'
```

### 4.8 Get Notifications by Student

```bash
curl -X GET $API_BASE/notifications/student/$STUDENT_ID \
  -H "Authorization: Bearer $TEACHER_TOKEN"
```

---

## 5. User Profile Management

### 5.1 Get Current User Profile

```bash
curl -X GET $API_BASE/users/profile/me \
  -H "Authorization: Bearer $TEACHER_TOKEN"
```

### 5.2 Update Current User Profile

```bash
curl -X PUT $API_BASE/users/profile/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -d '{
    "name": "Dr. Emily Brown Updated",
    "email": "emily.teacher@school.com"
  }'
```

### 5.3 Get All Users (Manager Only)

```bash
curl -X GET $API_BASE/users \
  -H "Authorization: Bearer $MANAGER_TOKEN"
```

### 5.4 Update User (Manager Only)

```bash
curl -X PUT $API_BASE/users/$TEACHER_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "name": "Dr. Emily Brown",
    "isActive": true
  }'
```

---

## 6. Complete Testing Scenario

### Scenario: Student Absence Verification Flow

```bash
#!/bin/bash

# 1. Receptionist creates request for student
echo "1. Receptionist sending request..."
NOTIF_RESPONSE=$(curl -s -X POST $API_BASE/notifications/request \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" \
  -d '{
    "studentId": "'$STUDENT_ID'",
    "message": "Is student Ahmad present in your class?"
  }')

NOTIFICATION_ID=$(echo $NOTIF_RESPONSE | jq -r '.data.notification._id')
echo "Created notification: $NOTIFICATION_ID"

# 2. Teacher checks notifications
echo -e "\n2. Teacher checking notifications..."
curl -s -X GET $API_BASE/notifications \
  -H "Authorization: Bearer $TEACHER_TOKEN" | jq

# 3. Teacher responds
echo -e "\n3. Teacher responding..."
curl -s -X PUT $API_BASE/notifications/$NOTIFICATION_ID/respond \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -d '{
    "status": "present",
    "responseMessage": "Yes, student is present"
  }' | jq

# 4. Receptionist checks response
echo -e "\n4. Receptionist checking response..."
curl -s -X GET $API_BASE/notifications \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" | jq

# 5. Receptionist marks as read
echo -e "\n5. Marking as read..."
curl -s -X PUT $API_BASE/notifications/$NOTIFICATION_ID/read \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" | jq

echo -e "\n✅ Complete workflow tested successfully!"
```

---

## 7. Error Testing

### 7.1 Test Unauthorized Access

```bash
# Try to create student without token
curl -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -d '{
    "studentCode": "STU999",
    "nama": "Test Student"
  }'

# Expected: 401 Unauthorized
```

### 7.2 Test Invalid Role Permissions

```bash
# Try to create student as receptionist (should fail)
curl -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" \
  -d '{
    "studentCode": "STU999",
    "nama": "Test Student"
  }'

# Expected: 403 Forbidden
```

### 7.3 Test Invalid Data

```bash
# Try to create student with duplicate code
curl -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentCode": "STU001",
    "nama": "Duplicate Student"
  }'

# Expected: 400 Bad Request
```

---

## 8. Postman Collection

Save this as `student-absence-api.postman_collection.json`:

```json
{
  "info": {
    "name": "Student Absence API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3000/api"
    },
    {
      "key": "manager_token",
      "value": ""
    },
    {
      "key": "teacher_token",
      "value": ""
    },
    {
      "key": "receptionist_token",
      "value": ""
    }
  ],
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Register Manager",
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"name\": \"Admin Manager\",\n  \"email\": \"manager@school.com\",\n  \"password\": \"manager123\",\n  \"role\": \"manager\"\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": "{{base_url}}/auth/register"
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"email\": \"manager@school.com\",\n  \"password\": \"manager123\"\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": "{{base_url}}/auth/login"
          }
        }
      ]
    }
  ]
}
```

---

## 9. Quick Test Commands

### One-liner to test full workflow:

```bash
# Set these first
export API_BASE="http://localhost:3000/api"
export MANAGER_TOKEN="your-manager-token"
export TEACHER_ID="your-teacher-id"
export STUDENT_ID="your-student-id"

# Then run this complete test
echo "Creating class..." && \
curl -s -X POST $API_BASE/classes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{"name":"Test Class","teacher":"'$TEACHER_ID'","capacity":30}' | jq '.data.class._id' && \
echo "✅ Setup complete!"
```

---

## 10. Troubleshooting

### Backend not responding?

```bash
# Check if backend is running
curl http://localhost:3000/health

# Check backend logs
# (in your backend terminal)
```

### Invalid token errors?

```bash
# Re-login to get fresh token
curl -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"manager@school.com","password":"manager123"}'
```

### CORS errors?

The backend should have CORS enabled. If testing from browser/Flutter app, ensure CORS middleware is configured in the backend.

---

## Next Steps

After verifying API works with curl:

1. ✅ Test all auth endpoints
2. ✅ Create manager, teacher, receptionist accounts
3. ✅ Create students and classes
4. ✅ Test notification workflow
5. 🔄 Integrate Flutter app with API
6. 🔄 Add Socket.IO for real-time updates

**Ready to integrate with Flutter app!** 🚀

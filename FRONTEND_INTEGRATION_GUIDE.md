# 📋 Complete API Reference - Student Absence System

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
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"manager@school.com","password":"password123"}'
```

**Response:**
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "user_id",
      "name": "Manager Name",
      "email": "manager@school.com",
      "role": "manager"
    }
  }
}
```

### 2. Get Current User
```bash
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 ENDPOINTS BY ROLE

### 👨‍💼 MANAGER (Full Access)

#### Students Management

| Action | Method | Endpoint | Body | Response |
|--------|--------|----------|------|----------|
| Get all students | GET | `/students?page=1&limit=10` | - | Paginated list |
| Get student by ID | GET | `/students/:id` | - | Single student |
| Get students by class | GET | `/students/class/:classId` | - | Student list |
| Create student | POST | `/students` | `{ studentCode, nama, class, enrollmentDate }` | Created student |
| Update student | PUT | `/students/:id` | `{ nama, class, isActive }` | Updated student |
| Delete student | DELETE | `/students/:id` | - | Success message |

**Create Student Example:**
```bash
curl -X POST http://localhost:3000/api/students \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "studentCode": "STU001",
    "nama": "Ahmad Abdullah",
    "class": "class_id_here",
    "enrollmentDate": "2024-10-22"
  }'
```

#### Classes Management

| Action | Method | Endpoint | Body | Response |
|--------|--------|----------|------|----------|
| Get all classes | GET | `/classes?page=1&limit=10` | - | Paginated list |
| Get class by ID | GET | `/classes/:id` | - | Single class |
| Get classes by teacher | GET | `/classes/teacher/:teacherId` | - | Class list |
| Create class | POST | `/classes` | `{ name, description, teacher, capacity, startDate }` | Created class |
| Update class | PUT | `/classes/:id` | `{ name, capacity, isActive }` | Updated class |
| Delete class | DELETE | `/classes/:id` | - | Success message |
| Add student to class | POST | `/classes/:id/students` | `{ studentId }` | Updated class |
| Remove student | DELETE | `/classes/:id/students/:studentId` | - | Updated class |

**Create Class Example:**
```bash
curl -X POST http://localhost:3000/api/classes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mathematics 101",
    "description": "Basic mathematics course",
    "teacher": "teacher_user_id",
    "capacity": 30,
    "startDate": "2024-10-22"
  }'
```

#### User Management

| Action | Method | Endpoint | Body |
|--------|--------|----------|------|
| Get all users | GET | `/users?page=1&limit=10` | - |
| Get user by ID | GET | `/users/:id` | - |
| Update user | PUT | `/users/:id` | `{ name, email, avatar }` |
| Delete user | DELETE | `/users/:id` | - |

---

### 👨‍🏫 TEACHER

#### View Access

| Action | Method | Endpoint |
|--------|--------|----------|
| Get my classes | GET | `/classes/teacher/:myUserId` |
| Get students in class | GET | `/students/class/:classId` |
| Get student by ID | GET | `/students/:id` |

#### Notifications

| Action | Method | Endpoint | Body |
|--------|--------|----------|------|
| Get my notifications | GET | `/notifications?page=1&limit=10` | - |
| Get notification by ID | GET | `/notifications/:id` | - |
| Respond to request | PUT | `/notifications/:id/respond` | `{ status, responseMessage }` |
| Send message to receptionist | POST | `/notifications/message` | `{ receptionistId, studentId, message }` |
| Mark as read | PUT | `/notifications/:id/read` | - |
| Get unread count | GET | `/notifications/unread/count` | - |

**Respond to Notification:**
```bash
curl -X PUT http://localhost:3000/api/notifications/notif_id/respond \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "present",
    "responseMessage": "Yes, student is present in class"
  }'
```

**Send Message to Receptionist:**
```bash
curl -X POST http://localhost:3000/api/notifications/message \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "receptionistId": "receptionist_user_id",
    "studentId": "student_id",
    "message": "Please send student to principal office"
  }'
```

---

### 👩‍💼 RECEPTIONIST

#### View Access

| Action | Method | Endpoint |
|--------|--------|----------|
| Get all students | GET | `/students?page=1&limit=10` |
| Get student by ID | GET | `/students/:id` |
| Get all classes | GET | `/classes?page=1&limit=10` |
| Get class by ID | GET | `/classes/:id` |

#### Notifications

| Action | Method | Endpoint | Body |
|--------|--------|----------|------|
| Send request to teacher | POST | `/notifications/request` | `{ studentId, message }` |
| Get my notifications | GET | `/notifications?page=1&limit=10` | - |
| Get notification by ID | GET | `/notifications/:id` | - |
| Get notifications by student | GET | `/notifications/student/:studentId` | - |
| Mark as read | PUT | `/notifications/:id/read` | - |
| Get unread count | GET | `/notifications/unread/count` | - |

**Send Request:**
```bash
curl -X POST http://localhost:3000/api/notifications/request \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": "student_id",
    "message": "Is student Ahmad present in your class?"
  }'
```

---

## 🎯 COMMON WORKFLOWS

### Workflow 1: Receptionist Checks Student Presence

```bash
# Step 1: Get student information
curl http://localhost:3000/api/students/student_id \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN"

# Step 2: Send request to teacher
curl -X POST http://localhost:3000/api/notifications/request \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"studentId":"student_id","message":"Is student present?"}'

# Step 3: Poll or wait for socket event
curl http://localhost:3000/api/notifications \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN"
```

### Workflow 2: Teacher Responds

```bash
# Step 1: Get pending notifications
curl http://localhost:3000/api/notifications \
  -H "Authorization: Bearer $TEACHER_TOKEN"

# Step 2: Respond to request
curl -X PUT http://localhost:3000/api/notifications/notif_id/respond \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"present","responseMessage":"Yes, student is here"}'
```

### Workflow 3: Manager Sets Up New Class

```bash
# Step 1: Create the class
CLASS_RESPONSE=$(curl -X POST http://localhost:3000/api/classes \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Math 101",
    "teacher": "teacher_id",
    "capacity": 30,
    "startDate": "2024-10-22"
  }')

# Extract class ID from response
CLASS_ID=$(echo $CLASS_RESPONSE | grep -o '"_id":"[^"]*' | cut -d'"' -f4)

# Step 2: Create students
curl -X POST http://localhost:3000/api/students \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "studentCode": "STU001",
    "nama": "Ahmad Abdullah",
    "class": "'$CLASS_ID'",
    "enrollmentDate": "2024-10-22"
  }'

# Step 3: Or add existing students
curl -X POST http://localhost:3000/api/classes/$CLASS_ID/students \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"studentId":"existing_student_id"}'
```

---

## 🔌 SOCKET.IO REAL-TIME EVENTS

### Connection Setup

```javascript
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000', {
  auth: {
    userId: currentUser._id  // Pass authenticated user ID
  }
});

socket.on('connect', () => {
  console.log('Connected to Socket.IO server');
  console.log('Socket ID:', socket.id);
});

socket.on('disconnect', () => {
  console.log('Disconnected from server');
});
```

### Events to Listen For

#### 1. notification:new
Triggered when a new notification is created (request or message sent)

```javascript
socket.on('notification:new', (data) => {
  console.log('New notification received:', data);
  /*
  data = {
    id: "notification_id",
    type: "request" | "message",
    status: "pending",
    student: {
      id: "student_id",
      studentCode: "STU001",
      nama: "Ahmad Abdullah"
    },
    class: {
      id: "class_id",
      name: "Math 101"
    },
    message: "Is student present?",
    createdAt: "2024-10-22T10:30:00.000Z"
  }
  */
  
  // Update UI
  addNotificationToList(data);
  updateBadgeCount();
  showToast('New notification received');
});
```

#### 2. notification:updated
Triggered when teacher responds to a request

```javascript
socket.on('notification:updated', (data) => {
  console.log('Notification updated:', data);
  /*
  data = {
    id: "notification_id",
    status: "present" | "absent" | "approved" | "rejected",
    responseMessage: "Yes, student is present",
    responseDate: "2024-10-22T10:35:00.000Z"
  }
  */
  
  // Update specific notification in list
  updateNotificationInList(data.id, data);
  showToast('Teacher responded');
});
```

#### 3. notification:read
Triggered when recipient marks notification as read

```javascript
socket.on('notification:read', (data) => {
  console.log('Notification read:', data);
  /*
  data = {
    id: "notification_id",
    readBy: "user_id",
    readAt: "2024-10-22T10:40:00.000Z"
  }
  */
  
  // Update read status in sender's view
  markAsRead(data.id);
});
```

### Flutter Socket.IO Example

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  
  void connect(String userId) {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'auth': {'userId': userId},
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    socket.on('connect', (_) {
      print('Connected to Socket.IO');
    });
    
    socket.on('notification:new', (data) {
      print('New notification: $data');
      // Update UI using state management
    });
    
    socket.on('notification:updated', (data) {
      print('Notification updated: $data');
      // Update specific notification
    });
    
    socket.connect();
  }
  
  void disconnect() {
    socket.disconnect();
  }
}
```

---

## 📦 RESPONSE FORMATS

### Success Response
```json
{
  "status": "success",
  "data": {
    "student": { ... }
  },
  "message": "Student created successfully"
}
```

### Paginated Response
```json
{
  "status": "success",
  "results": 10,
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalPages": 5,
    "totalResults": 50
  },
  "data": {
    "students": [ ... ]
  }
}
```

### Error Response
```json
{
  "status": "fail",
  "message": "Student code already exists",
  "errors": [
    {
      "field": "studentCode",
      "message": "STU001 is already in use"
    }
  ]
}
```

---

## 🔑 NOTIFICATION STATUS VALUES

| Status | Description | Set By |
|--------|-------------|--------|
| `pending` | Waiting for teacher response | System (on creation) |
| `present` | Student is present in class | Teacher |
| `absent` | Student is absent | Teacher |
| `approved` | Request approved | Teacher |
| `rejected` | Request rejected | Teacher |

---

## 🎨 NOTIFICATION TYPES

| Type | Flow | Created Via Endpoint |
|------|------|---------------------|
| `request` | Receptionist → Teacher | `POST /notifications/request` |
| `response` | Teacher → Receptionist (auto) | `PUT /notifications/:id/respond` |
| `message` | Teacher → Receptionist | `POST /notifications/message` |

---

## 🧪 TEST CREDENTIALS

```
Manager:      manager@school.com      / password123
Teacher 1:    teacher1@school.com     / password123
Teacher 2:    teacher2@school.com     / password123
Receptionist: receptionist@school.com / password123
```

---

## 🚨 HTTP STATUS CODES

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Successful GET, PUT, DELETE |
| 201 | Created | Successful POST |
| 400 | Bad Request | Invalid data, validation error |
| 401 | Unauthorized | No token or invalid token |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource doesn't exist |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

---

## 🔧 DEVELOPMENT TIPS

### Store Token Securely (Flutter)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Save token
await storage.write(key: 'auth_token', value: token);

// Read token
String? token = await storage.read(key: 'auth_token');

// Delete token
await storage.delete(key: 'auth_token');
```

### API Service Base Setup (Flutter)

```dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - logout user
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }
  
  // ... more methods
}
```

---

## 📞 SUPPORT ENDPOINTS

```bash
# Check server health
curl http://localhost:3000/health

# View Swagger API documentation
open http://localhost:3000/api-docs
```

---

**Need help?** Check `TESTING_SUMMARY.md` or `START_HERE_TESTING.md`

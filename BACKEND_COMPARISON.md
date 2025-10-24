# Backend vs Frontend Comparison - Student Absence System

## 📊 Overview
This document compares the **Node.js Backend** (from GitHub repo) with the **Flutter Frontend** (current implementation).

---

## 🔍 Major Differences Found

### 1. **User Roles**
| Backend | Frontend |
|---------|----------|
| ✅ `manager` | ❌ **Missing** - Uses `dean` instead |
| ✅ `teacher` | ✅ Implemented |
| ✅ `receptionist` | ✅ Implemented |
| ❌ No `dean` role | ✅ Has `dean` role |

**⚠️ Issue**: Backend has no `dean` role, only `manager`. Frontend should align with backend.

---

### 2. **Teacher-Class Relationship**

#### Backend Structure:
```javascript
// Class Model
{
  teacher: ObjectId,  // ONE teacher per class
  students: [ObjectId],
  capacity: Number
}
```

#### Frontend Structure:
```dart
// UserModel
{
  classNames: List<String>,  // MULTIPLE classes per teacher
  handlesAllClasses: bool
}
```

**⚠️ Critical Mismatch**: 
- **Backend**: Each class has ONE teacher (many-to-one)
- **Frontend**: Each teacher can manage MULTIPLE classes (one-to-many)

**Backend Logic**:
```javascript
// Teacher can have multiple classes
GET /api/classes/teacher/:teacherId
// Returns all classes where teacher === teacherId
```

**✅ Frontend Implementation is Correct** - Teachers can manage multiple classes, which the backend supports!

---

### 3. **Student Model**

#### Backend:
```javascript
{
  studentCode: String (unique, uppercase),
  nama: String,  // Indonesian for "name"
  class: ObjectId (reference),
  isActive: Boolean,
  enrollmentDate: Date
}
```

#### Frontend:
```dart
// RequestModel (representing student in request)
{
  studentName: String,
  className: String  // Not ObjectId
}
```

**⚠️ Issues**:
1. **No Student entity in frontend** - should be added
2. Field name: Backend uses `nama` (Indonesian), frontend uses `studentName`
3. Backend uses `studentCode` as unique identifier
4. Backend links student to class via ObjectId reference

---

### 4. **Class Model**

#### Backend:
```javascript
{
  name: String,
  description: String,
  teacher: ObjectId (required),
  students: [ObjectId],
  capacity: Number (1-100),
  isActive: Boolean,
  startDate: Date,
  endDate: Date
}
```

#### Frontend:
```dart
// Simple string representation
className: String  // e.g., "Class A", "Class B"
```

**⚠️ Missing in Frontend**:
- No Class entity/model
- No class capacity management
- No teacher assignment to classes
- No student roster per class

---

### 5. **Notification/Request System**

#### Backend Notification Model:
```javascript
{
  from: ObjectId (User),
  to: ObjectId (User),
  student: ObjectId (Student),
  class: ObjectId (Class),
  type: "request" | "response" | "message",
  status: "pending" | "approved" | "rejected" | "absent" | "present",
  message: String,
  responseMessage: String,
  isRead: Boolean,
  requestDate: Date,
  responseDate: Date
}
```

#### Frontend RequestModel:
```dart
{
  id: String,
  studentName: String,
  className: String,
  status: String,  // "pending", "Accepted", "Not Found"
  createdBy: String,
  createdAt: DateTime
}
```

**⚠️ Major Differences**:

| Feature | Backend | Frontend |
|---------|---------|----------|
| **Status Values** | `approved`, `rejected`, `absent`, `present` | `Accepted`, `Not Found` |
| **Bidirectional** | Yes (from/to users) | No (only `createdBy`) |
| **Student Reference** | ObjectId to Student entity | Just string name |
| **Class Reference** | ObjectId to Class entity | Just string name |
| **Response Message** | ✅ Has `responseMessage` | ❌ Missing |
| **Read Status** | ✅ Has `isRead` flag | ❌ Missing |
| **Message Types** | 3 types: request, response, message | Only 1 type (request) |

---

### 6. **Notification Workflow**

#### Backend Supports TWO workflows:

**A) Receptionist → Teacher (request/response)**
```javascript
// 1. Receptionist sends request
POST /api/notifications/request
{
  "studentId": "student_id",
  "message": "Need to verify student attendance"
}

// 2. Teacher responds
PUT /api/notifications/:id/respond
{
  "status": "present|absent|approved|rejected",
  "responseMessage": "Student is present in class"
}
```

**B) Teacher → Receptionist (proactive message)**
```javascript
POST /api/notifications/message
{
  "receptionistId": "user_id",
  "studentId": "student_id",
  "message": "Please send the student to the office"
}
```

#### Frontend Only Supports:
- ✅ Receptionist creates requests
- ✅ Teacher responds (Accept/Not Found)
- ❌ **Missing**: Teacher → Receptionist messaging

---

### 7. **Authentication & Authorization**

#### Backend:
```javascript
// JWT-based authentication
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/forgot-password
PUT /api/auth/reset-password/:token

// Password requirements
- Minimum 8 characters
- Hashed with bcrypt (12 rounds)
- Token expiration handling
```

#### Frontend:
```dart
// Simple mock authentication
- No JWT tokens
- No password hashing
- No password reset
- In-memory user storage
```

**⚠️ Critical Security Gap**: Frontend has no real authentication system.

---

### 8. **Real-time Communication**

#### Backend:
```javascript
// Socket.IO WebSocket implementation
Events:
- notification:new
- notification:updated
- notification:read

// Auto-join room: user:{userId}
```

#### Frontend:
```dart
// ❌ No WebSocket/real-time implementation
// Uses Cubit state management only
```

**⚠️ Missing Feature**: No real-time updates in frontend.

---

### 9. **API Endpoints Comparison**

#### Backend Has (Frontend Missing):

**Student Management:**
- `GET /api/students` - List all students
- `POST /api/students` - Create student (Manager only)
- `PUT /api/students/:id` - Update student
- `DELETE /api/students/:id` - Delete student
- `GET /api/students/class/:classId` - Get students by class

**Class Management:**
- `GET /api/classes` - List all classes
- `POST /api/classes` - Create class (Manager only)
- `PUT /api/classes/:id` - Update class
- `DELETE /api/classes/:id` - Delete class
- `GET /api/classes/teacher/:teacherId` - Get teacher's classes ✅
- `POST /api/classes/:id/students` - Add student to class
- `DELETE /api/classes/:id/students/:studentId` - Remove student

**User Management:**
- `GET /api/users` - List users (Manager only)
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `GET /api/users/profile/me` - Get profile ✅
- `PUT /api/users/profile/me` - Update profile ✅

**Notification Extras:**
- `GET /api/notifications/unread/count` - Unread count
- `GET /api/notifications/student/:studentId` - By student
- `PUT /api/notifications/:id/read` - Mark as read
- `POST /api/notifications/message` - Teacher → Receptionist

---

## 📋 What Needs to be Added to Frontend

### 1. **High Priority - Data Models**

#### Create Student Model:
```dart
class StudentModel {
  final String id;
  final String studentCode;  // Unique identifier
  final String nama;         // Name
  final String classId;      // Reference to class
  final bool isActive;
  final DateTime enrollmentDate;
}
```

#### Create Class Model:
```dart
class ClassModel {
  final String id;
  final String name;
  final String description;
  final String teacherId;    // Reference to teacher
  final List<String> studentIds;
  final int capacity;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
}
```

### 2. **Update UserModel**
```dart
class UserModel {
  // Change role from 'dean' to 'manager'
  final String role; // "teacher", "manager", "receptionist"
  
  // Teacher now managed via Class entities, not direct assignment
  // Remove classNames, handlesAllClasses
  // Teacher's classes are queried from Class entities
}
```

### 3. **Update RequestModel (→ NotificationModel)**
```dart
class NotificationModel {
  final String id;
  final String from;         // User ID who sent
  final String to;           // User ID who receives
  final String studentId;    // Reference to Student
  final String classId;      // Reference to Class
  final String type;         // "request", "response", "message"
  final String status;       // "pending", "approved", "rejected", "absent", "present"
  final String? message;
  final String? responseMessage;
  final bool isRead;
  final DateTime requestDate;
  final DateTime? responseDate;
}
```

### 4. **Add Missing Features**

#### A) Dean/Manager Dashboard (NEW)
- User management (CRUD)
- Class management (CRUD)
- Student management (CRUD)
- System statistics

#### B) Teacher Messaging
```dart
// Teacher can send messages to receptionist
Future<void> sendMessageToReceptionist({
  required String receptionistId,
  required String studentId,
  required String message,
});
```

#### C) Real-time Updates
- Integrate Socket.IO client
- Listen for notification events
- Auto-refresh UI on updates

#### D) Authentication System
- JWT token storage (secure_storage)
- Token refresh logic
- Password hashing
- Forgot/reset password flow

### 5. **Update Status Values**
```dart
// Change from:
"Accepted", "Not Found"

// To backend format:
"approved", "rejected", "absent", "present"
```

### 6. **Add API Integration**
```dart
// Replace mock data with HTTP calls
class ApiService {
  static const baseUrl = 'http://your-backend-url';
  
  // Auth
  Future<void> login(String email, String password);
  Future<void> register(UserModel user);
  
  // Students
  Future<List<StudentModel>> getStudents();
  Future<StudentModel> createStudent(StudentModel student);
  
  // Classes
  Future<List<ClassModel>> getClasses();
  Future<List<ClassModel>> getTeacherClasses(String teacherId);
  
  // Notifications
  Future<List<NotificationModel>> getNotifications();
  Future<void> respondToNotification(String id, String status, String message);
  Future<void> sendRequest(String studentId, String message);
  Future<void> sendTeacherMessage(String receptionistId, String studentId, String message);
}
```

---

## 🎯 Recommended Action Plan

### Phase 1: Core Models (Week 1)
- [ ] Create `StudentModel`
- [ ] Create `ClassModel`
- [ ] Rename `RequestModel` → `NotificationModel`
- [ ] Update `UserModel` (change dean → manager)
- [ ] Update mock data to match backend structure

### Phase 2: API Integration (Week 2)
- [ ] Add `http` and `dio` packages
- [ ] Create `ApiService` class
- [ ] Implement authentication endpoints
- [ ] Implement student/class endpoints
- [ ] Implement notification endpoints
- [ ] Add JWT token management

### Phase 3: Manager Features (Week 3)
- [ ] Create Manager home screen
- [ ] Add student management (CRUD)
- [ ] Add class management (CRUD)
- [ ] Add user management (CRUD)
- [ ] Add capacity validation

### Phase 4: Real-time Updates (Week 4)
- [ ] Integrate `socket_io_client` package
- [ ] Implement WebSocket connection
- [ ] Listen to notification events
- [ ] Update UI in real-time
- [ ] Add read/unread status

### Phase 5: Enhanced Features (Week 5)
- [ ] Teacher → Receptionist messaging
- [ ] Notification response messages
- [ ] Unread notification badges
- [ ] Student code scanning/input
- [ ] Class capacity warnings
- [ ] Forgot password flow

---

## 📦 Required Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  # HTTP Client
  dio: ^5.4.0
  
  # WebSocket
  socket_io_client: ^2.0.3+1
  
  # Secure Storage (for JWT)
  flutter_secure_storage: ^9.0.0
  
  # Better state management for API calls
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  # Code generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
```

---

## ⚖️ Backend Alignment Summary

| Feature | Backend | Frontend | Action Required |
|---------|---------|----------|-----------------|
| **User Roles** | manager, teacher, receptionist | dean, teacher, receptionist | ⚠️ Change dean → manager |
| **Student Entity** | ✅ Full model | ❌ Missing | 🔴 **Create StudentModel** |
| **Class Entity** | ✅ Full model | ❌ Missing | 🔴 **Create ClassModel** |
| **Teacher-Class** | ✅ Many-to-one | ✅ Many-to-many | ✅ Already compatible |
| **Notifications** | ✅ Bidirectional, 3 types | ⚠️ One-way only | 🟡 **Add teacher messaging** |
| **Status Values** | approved/rejected/absent/present | Accepted/Not Found | ⚠️ **Update to match backend** |
| **Real-time** | ✅ Socket.IO | ❌ Missing | 🔴 **Add WebSocket** |
| **Authentication** | ✅ JWT, bcrypt | ❌ Mock only | 🔴 **Implement JWT auth** |
| **API Integration** | ✅ RESTful | ❌ Mock data | 🔴 **Connect to backend** |
| **Manager Dashboard** | ✅ Full CRUD | ❌ Missing | 🔴 **Build manager screens** |
| **Capacity Management** | ✅ Class capacity limits | ❌ Missing | 🟡 **Add validation** |

---

## 🚀 Quick Start Integration

### 1. Update Environment Config
Create `.env` file:
```
API_BASE_URL=http://your-backend-url/api
SOCKET_URL=http://your-backend-url
```

### 2. Create API Constants
```dart
class ApiConstants {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static const socketUrl = String.fromEnvironment('SOCKET_URL');
  
  // Auth endpoints
  static const login = '/auth/login';
  static const register = '/auth/register';
  
  // Notification endpoints
  static const notifications = '/notifications';
  static const notificationRequest = '/notifications/request';
  static const notificationRespond = '/notifications/:id/respond';
  static const notificationMessage = '/notifications/message';
}
```

---

## 📝 Conclusion

**Current Status**: Frontend has ~50% of backend functionality implemented.

**Major Gaps**:
1. ❌ No Student/Class entity management
2. ❌ No Manager role and dashboard
3. ❌ No real API integration (using mock data)
4. ❌ No real-time WebSocket updates
5. ❌ No JWT authentication
6. ⚠️ Different role names (dean vs manager)
7. ⚠️ Different status values

**Strengths**:
1. ✅ Multiple class assignment for teachers (compatible)
2. ✅ Basic request/response flow works
3. ✅ Profile management structure exists
4. ✅ Responsive UI is complete
5. ✅ State management (Cubit) is solid

**Recommendation**: Start with Phase 1 (Core Models) to align data structures, then proceed to API integration.

---

**Last Updated**: October 22, 2025
**Backend Repo**: [0xEbrahim/Student-Absence](https://github.com/0xEbrahim/Student-Absence)

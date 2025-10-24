# Testing Your Backend API - Complete Guide

## 🎯 Quick Start

Your backend is running on **http://localhost:3000**

### Option 1: Interactive Tester (Easiest) ⭐

```bash
./interactive_test.sh
```

This script provides a menu to test all endpoints interactively.

### Option 2: Simple Manual Tests

```bash
# 1. Check if backend is running
curl http://localhost:3000/health

# 2. View API documentation
curl http://localhost:3000/api/docs

# 3. Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@test.com",
    "password": "password123",
    "confirmPassword": "password123"
  }'

# 4. Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@test.com",
    "password": "password123"
  }'
```

## 📚 Available Documentation Files

1. **ACTUAL_API_GUIDE.md** - Current API structure based on /api/docs
2. **API_TESTING_GUIDE.md** - Original comprehensive guide (may have outdated info)
3. **QUICK_API_TEST.md** - Quick reference card
4. **This file** - Simple testing instructions

## 🔍 What We Know About Your API

### ✅ Confirmed Working:
- Health check: `GET /health`
- API docs: `GET /api/docs`
- Registration: `POST /api/auth/register` (requires `confirmPassword`)
- Login: `POST /api/auth/login`
- Get current user: `GET /api/auth/me`
- Profile endpoints: `/api/users/profile/me`

### ❓ Need to Verify:
- Student endpoints (`/api/students/*`)
- Class endpoints (`/api/classes/*`)
- Notification endpoints (`/api/notifications/*`)
- How roles are assigned (manager, teacher, receptionist)
- Whether Socket.IO is enabled

## 🚀 Next Steps for Flutter Integration

### Step 1: Verify All Endpoints

Check your backend code to find:
```bash
# Look for routes in your backend
# Common locations:
# - routes/studentRoutes.js
# - routes/classRoutes.js
# - routes/notificationRoutes.js
```

### Step 2: Test Complete Workflow

1. **Register 3 users:**
   - Manager
   - Teacher
   - Receptionist

2. **Create students** (as manager)
3. **Create classes** (as manager)
4. **Assign teacher to class**
5. **Send notification** (receptionist → teacher)
6. **Respond to notification** (teacher → receptionist)

### Step 3: Update Flutter App

Once you confirm all endpoints work:

1. **Add packages to pubspec.yaml:**
```yaml
dependencies:
  dio: ^5.4.0  # HTTP client
  socket_io_client: ^2.0.3  # Real-time notifications
  flutter_secure_storage: ^9.0.0  # Store JWT token securely
```

2. **Create API service:**
```dart
// lib/services/api_service.dart
class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    headers: {'Content-Type': 'application/json'},
  ));
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': password,
    });
    return response.data;
  }
  
  // ... more methods
}
```

3. **Update Cubits to use API:**
```dart
// lib/cubits/user_cubit.dart
class UserCubit extends Cubit<UserState> {
  final ApiService _apiService;
  
  Future<void> login(String email, String password) async {
    emit(UserLoading());
    try {
      final data = await _apiService.login(email, password);
      final user = UserModel.fromMap(data['data']['user']);
      emit(UserAuthenticated(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
```

## 🛠 Troubleshooting

### Backend hangs on registration?

**Check backend logs for:**
- Database connection errors
- Email service timeouts
- Password hashing issues

**Quick fix:** Comment out email sending in backend temporarily

### Can't find student/class endpoints?

**Look in backend code:**
```bash
# Check if routes are registered
grep -r "students" backend/routes/
grep -r "classes" backend/routes/
grep -r "notifications" backend/routes/
```

### Token expires quickly?

Check JWT expiration settings in backend:
```javascript
// Usually in backend/config or backend/utils
expiresIn: '7d'  // Adjust as needed
```

## 📝 Testing Checklist

- [ ] Backend health check works
- [ ] Can register a user
- [ ] Can login
- [ ] Can get current user with token
- [ ] Can update profile
- [ ] Found all student endpoints
- [ ] Found all class endpoints  
- [ ] Found all notification endpoints
- [ ] Tested complete workflow
- [ ] Ready to integrate with Flutter

## 🎓 Example Testing Session

```bash
# Start the interactive tester
./interactive_test.sh

# Select options in order:
# 1. View API Documentation (to see all endpoints)
# 2. Register a new user
#    Name: Test Manager
#    Email: manager@test.com
#    Password: password123
# 3. Login with same credentials
# 4. Get current user (verify token works)
# 5. Get my profile
# 6. Update profile

# Token will be saved to .api_token file
```

## 📞 Need Help?

1. **Check backend console** for error messages
2. **Check ACTUAL_API_GUIDE.md** for detailed endpoint info
3. **Run interactive_test.sh** for guided testing

---

**Your backend is running! 🎉**  
Use the interactive tester or manual curl commands to verify all endpoints work.

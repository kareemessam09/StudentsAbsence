# Backend Response Structure Fix ✅

## Problem: "type Null is not a subtype" Error on Login/Signup

### Root Cause
The Flutter app expected a different response structure from the backend than what was actually being returned.

---

## Backend Response Structure

### Login Response (`POST /auth/login`):
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "68f940214063a3aaf1959b29",
      "name": "Test User",
      "email": "test@school.com",
      "role": "receptionist",
      "avatar": "",
      "isActive": true,
      "createdAt": "2025-10-22T20:35:45.332Z",
      "updatedAt": "2025-10-22T20:36:04.978Z",
      "lastLogin": "2025-10-22T20:36:04.977Z"
    }
  }
}
```

### Register Response (`POST /auth/register`):
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "name": "Test User",
      "email": "test@school.com",
      "role": "receptionist",
      "avatar": "",
      "isActive": true,
      "_id": "68f940214063a3aaf1959b29",
      "createdAt": "2025-10-22T20:35:45.332Z",
      "updatedAt": "2025-10-22T20:35:45.332Z"
    }
  }
}
```

**Key Points:**
- ✅ Token is at top level: `response.data['token']`
- ✅ User is nested: `response.data['data']['user']`
- ✅ Backend uses `role` field (not `isManager`)

---

## What Was Wrong

### ❌ Old Code (AuthService):
```dart
// Login
final token = response.data['token'];
final user = UserModel.fromJson(response.data['user']); // ❌ NULL! user is not here

// Register
'isManager': isManager,  // ❌ Backend doesn't accept this field
```

**Error:** `response.data['user']` was `null` because the user is actually at `response.data['data']['user']`

---

## What Was Fixed

### ✅ New Code (AuthService):

#### 1. **Login Method:**
```dart
// Save token and user data
// Backend response structure: { status, token, data: { user } }
final token = response.data['token'];
final userData = response.data['data']?['user'] ?? response.data['user'];
final user = UserModel.fromJson(userData);
```

**Fix:** Try `data.user` first, fallback to `user` for backward compatibility

#### 2. **Register Method:**
```dart
// Backend expects 'role' field, not 'isManager'
// Convert isManager to role: manager, teacher, or receptionist
final String role = isManager ? 'manager' : 'receptionist';

final response = await _apiService.post(
  ApiEndpoints.register,
  data: {
    'name': name,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'role': role,  // ✅ Send 'role' instead of 'isManager'
  },
);

// Save token and user data
// Backend response structure: { status, token, data: { user } }
final token = response.data['token'];
final userData = response.data['data']?['user'] ?? response.data['user'];
final user = UserModel.fromJson(userData);
```

**Fixes:**
- ✅ Sends `role` field that backend expects
- ✅ Converts `isManager` to appropriate role
- ✅ Correctly accesses nested user object

#### 3. **GetMe Method:**
```dart
// Backend response structure: { status, data: { user } } or { user }
final userData = response.data['data']?['user'] ?? response.data['user'] ?? response.data;
final user = UserModel.fromJson(userData);
```

**Fix:** Multiple fallbacks for different response structures

---

## Files Modified

1. **`lib/services/auth_service.dart`**
   - ✅ Fixed `login()` method - now reads from `data.user`
   - ✅ Fixed `register()` method - sends `role` field, reads from `data.user`
   - ✅ Fixed `getMe()` method - reads from `data.user`

---

## Testing the Fix

### Test Login:
```bash
# 1. Create a user (or use existing)
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sarah Johnson",
    "email": "sarah@school.com",
    "password": "password123",
    "confirmPassword": "password123",
    "role": "receptionist"
  }'

# 2. Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah@school.com",
    "password": "password123"
  }'
```

### Test in Flutter App:
1. ✅ Run the app: `flutter run`
2. ✅ Try to login with: `sarah@school.com` / `password123`
3. ✅ Should successfully login and navigate to receptionist screen
4. ✅ No more "type Null is not a subtype" error!

---

## Backend Role Values

The backend accepts these role values:
- `receptionist` - Front desk staff
- `teacher` - Teachers
- `manager` - Managers/Deans/Administrators

**Signup Screen Mapping:**
- ☑️ "Register as Manager" unchecked → `role: 'receptionist'`
- ☑️ "Register as Manager" checked → `role: 'manager'`

**Note:** To create a teacher account, you need to:
1. Register as receptionist
2. Update role in MongoDB: `db.users.updateOne({email: "user@school.com"}, {$set: {role: "teacher"}})`

Or create a teacher registration option in the signup screen.

---

## Error Resolution

### Before Fix:
```
❌ type Null is not a subtype of type Map<String, dynamic>
❌ The method '[]' was called on null
❌ Null check operator used on a null value
```

### After Fix:
```
✅ Login successful
✅ User authenticated
✅ Navigation to home screen based on role
```

---

## Summary

**Issue:** Backend response structure mismatch causing null errors  
**Root Cause:** User data nested in `data.user` instead of direct `user`  
**Fix:** Updated AuthService to read from correct nested path  
**Additional Fix:** Changed `isManager` to `role` field for backend compatibility  
**Result:** Login and signup now work perfectly with backend! 🎉

---

## Test Users

After the fix, you can create test users:

```bash
# Receptionist
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Sarah Johnson","email":"sarah@school.com","password":"password123","confirmPassword":"password123","role":"receptionist"}'

# Manager
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Robert Dean","email":"robert@school.com","password":"password123","confirmPassword":"password123","role":"manager"}'
```

Then login with these credentials in the app! ✅

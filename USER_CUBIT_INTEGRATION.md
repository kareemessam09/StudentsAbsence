# ✅ UserCubit Integration Complete

## Overview
Successfully replaced UserCubit's mock authentication with real API integration using AuthService and UserService.

---

## Changes Made

### 1. **Added Dependency Injection** (`pubspec.yaml`)
```yaml
dependencies:
  get_it: ^7.6.4  # For dependency injection
```

### 2. **Created Service Locator** (`lib/config/service_locator.dart`)
```dart
final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register ApiService as singleton (shared instance)
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  
  // Register all other services with the same ApiService instance
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<ApiService>()));
  getIt.registerLazySingleton<StudentService>(() => StudentService(getIt<ApiService>()));
  getIt.registerLazySingleton<ClassService>(() => ClassService(getIt<ApiService>()));
  getIt.registerLazySingleton<NotificationService>(() => NotificationService(getIt<ApiService>()));
  getIt.registerLazySingleton<UserService>(() => UserService(getIt<ApiService>()));
}
```

**Benefits:**
- ✅ All services share the same ApiService instance
- ✅ Centralized configuration
- ✅ Easy to test (can mock services)
- ✅ Lazy loading (services created only when needed)

### 3. **Updated UserCubit** (`lib/cubits/user_cubit.dart`)

**Removed:**
- ❌ Mock `_users` list
- ❌ UUID generation
- ❌ Simulated delays (`await Future.delayed`)
- ❌ Local email validation logic
- ❌ `allUsers` getter

**Added:**
```dart
final AuthService _authService = getIt<AuthService>();
final UserService _userService = getIt<UserService>();
```

**New Methods:**
- ✅ `checkAuthStatus()` - Restores login from saved JWT tokens on app start
- ✅ `updatePassword()` - Password change via API

**Updated Methods:**
- ✅ `login()` - Now calls `_authService.login()`, returns `Map<String, dynamic>`
- ✅ `signup()` - NEW signature: `(name, email, password, confirmPassword, isManager)`
- ✅ `logout()` - Calls `_authService.logout()`, clears secure storage
- ✅ `updateProfile()` - Calls `_userService.updateMyProfile()`

### 4. **Updated Signup Screen** (`lib/screens/signup_screen.dart`)

**Changed signup call:**
```dart
// OLD (Mock API)
cubit.signup(
  name: ...,
  email: ...,
  password: ...,
  role: _selectedRole,  // String: 'receptionist', 'teacher', 'dean'
  classNames: _selectedClasses.toList(),
  handlesAllClasses: _handlesAllClasses,
);

// NEW (Real API)
cubit.signup(
  name: ...,
  email: ...,
  password: ...,
  confirmPassword: _confirmPasswordController.text,
  isManager: _selectedRole == 'manager',  // Boolean
);
```

**Changed role dropdown:**
- ✅ `'dean'` → `'manager'`
- ✅ `'Dean'` → `'Manager'`

**Removed:**
- ❌ Teacher class selection UI (backend now assigns classes differently)

### 5. **Updated Main App** (`lib/main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  await setupServiceLocator();
  
  runApp(const StudentNotifier());
}

// ...

BlocProvider(
  create: (context) {
    final cubit = UserCubit();
    // Check for saved login on app start
    cubit.checkAuthStatus();
    return cubit;
  },
),
```

**What this does:**
1. Initializes Flutter bindings (required for async operations in main)
2. Sets up all services before app starts
3. Checks if user was previously logged in
4. Automatically logs in if JWT token is valid

---

## API Integration Details

### Authentication Flow

#### **Login:**
```
User enters email/password
    ↓
UserCubit.login()
    ↓
AuthService.login() → POST /api/auth/login
    ↓
Backend returns: { success, token, user }
    ↓
Token saved to flutter_secure_storage
    ↓
emit(UserAuthenticated(user))
    ↓
Navigate to appropriate screen
```

#### **Signup:**
```
User fills signup form
    ↓
UserCubit.signup()
    ↓
AuthService.register() → POST /api/auth/register
    ↓
Backend returns: { success, token, user }
    ↓
Token saved to flutter_secure_storage
    ↓
emit(UserAuthenticated(user))
    ↓
Navigate to appropriate screen
```

#### **Auto-login on App Start:**
```
App starts
    ↓
main.dart calls setupServiceLocator()
    ↓
UserCubit.checkAuthStatus() called
    ↓
AuthService.isLoggedIn() checks for saved token
    ↓
If token exists → AuthService.getSavedUser()
    ↓
emit(UserAuthenticated(user))
    ↓
User stays logged in!
```

#### **Logout:**
```
User clicks logout
    ↓
UserCubit.logout()
    ↓
AuthService.logout() → clears tokens from secure storage
    ↓
emit(UserUnauthenticated())
    ↓
Navigate to login screen
```

---

## Backend API Endpoints Used

### AuthService:
- `POST /api/auth/register` - Create new user account
  - Body: `{ name, email, password, confirmPassword, isManager }`
  - Returns: `{ success, token, user, message }`

- `POST /api/auth/login` - User login
  - Body: `{ email, password }`
  - Returns: `{ success, token, user, message }`

- `PUT /api/auth/password` - Update password
  - Headers: `Authorization: Bearer <token>`
  - Body: `{ currentPassword, newPassword, confirmPassword }`
  - Returns: `{ success, message }`

### UserService:
- `GET /api/users/me` - Get current user profile
  - Headers: `Authorization: Bearer <token>`
  - Returns: `{ success, user }`

- `PUT /api/users/me` - Update user profile
  - Headers: `Authorization: Bearer <token>`
  - Body: `{ name?, email? }`
  - Returns: `{ success, user, message }`

---

## Token Management

### Storage:
- **Package:** `flutter_secure_storage`
- **Keys:**
  - `auth_token` - JWT access token
  - `user_data` - User object as JSON string

### Auto-injection:
- All API requests automatically include JWT token in `Authorization` header
- Handled by Dio interceptor in `ApiService`
- No need to manually add tokens to requests!

### Auto-logout:
- If API returns 401 Unauthorized → token expired
- Interceptor automatically clears tokens and navigates to login
- User sees error message

---

## Testing Instructions

### 1. Start Backend Server:
```bash
cd backend
npm start
```

Backend should be running at: `http://localhost:3000`

### 2. Run Flutter App:
```bash
flutter run
```

### 3. Test Signup:
1. Click "Create Account" on login screen
2. Fill in:
   - Name: `John Doe`
   - Email: `john@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
   - Role: `Teacher`, `Receptionist`, or `Manager`
3. Click "Sign Up"
4. Should navigate to appropriate home screen
5. JWT token saved in secure storage

### 4. Test Login:
1. Use existing credentials:
   - **Manager:** `manager@school.com` / `password123`
   - **Teacher:** `teacher@school.com` / `password123`
   - **Receptionist:** `receptionist@school.com` / `password123`
2. Click "Login"
3. Should navigate to appropriate home screen

### 5. Test Auto-login:
1. Login with any user
2. Close the app (don't logout)
3. Relaunch the app
4. Should automatically login and navigate to home screen (no login screen!)

### 6. Test Logout:
1. Login with any user
2. Navigate to profile screen
3. Click logout button
4. Should navigate to login screen
5. JWT token cleared from storage

### 7. Test Profile Update:
1. Login with any user
2. Go to profile screen
3. Change name or email
4. Click "Update Profile"
5. Should see success message
6. Backend should update user data

### 8. Test Password Change:
1. Login with any user
2. Go to profile screen
3. Enter:
   - Current Password: `password123`
   - New Password: `newpassword123`
   - Confirm Password: `newpassword123`
4. Click "Update Password"
5. Should see success message
6. Logout and login with new password

---

## Debugging Tips

### Check API Logs:
- Open Flutter DevTools console
- Should see pretty-printed API logs from `pretty_dio_logger`:
  ```
  ┌──────────────────────────────────────────────────────────────
  │ POST http://localhost:3000/api/auth/login
  │ Headers:
  │   Content-Type: application/json
  │ Body:
  │   {"email":"teacher@school.com","password":"password123"}
  ├──────────────────────────────────────────────────────────────
  │ 200 OK
  │ Response:
  │   {"success":true,"token":"eyJhbGc...","user":{...}}
  └──────────────────────────────────────────────────────────────
  ```

### Check Saved Tokens:
Add this to UserCubit for debugging:
```dart
Future<void> debugTokens() async {
  final token = await _authService.storage.read(key: 'auth_token');
  final userData = await _authService.storage.read(key: 'user_data');
  print('Token: $token');
  print('User: $userData');
}
```

### Common Errors:

**"Network error" / "Connection refused":**
- ✅ Make sure backend is running: `cd backend && npm start`
- ✅ Check `lib/config/api_config.dart` has correct URL
- ✅ For Android emulator, use `http://10.0.2.2:3000` instead of `localhost:3000`

**"Invalid credentials":**
- ✅ Check email/password are correct
- ✅ Check backend database has test users
- ✅ Run backend seeder: `npm run seed` (if available)

**"Token expired" / Auto-logout:**
- ✅ JWT tokens expire after certain time (check backend config)
- ✅ User needs to login again
- ✅ Consider implementing refresh tokens for production

**"User not found" on auto-login:**
- ✅ Backend user might have been deleted
- ✅ App will automatically logout and show login screen
- ✅ This is expected behavior

---

## Next Steps

### Completed ✅
- [x] Add get_it dependency injection
- [x] Create service locator
- [x] Update UserCubit to use AuthService
- [x] Update main.dart to call setupServiceLocator()
- [x] Add checkAuthStatus for auto-login

### Remaining Tasks 🟡

#### 1. **Update RequestCubit → NotificationCubit**
   - Rename file: `lib/cubits/request_cubit.dart` → `notification_cubit.dart`
   - Replace mock data with `NotificationService` API calls
   - Update all imports in screens

#### 2. **Create Socket.IO Service for Real-time Updates**
   - Create `lib/services/socket_service.dart`
   - Connect on login, disconnect on logout
   - Listen to: `notification:new`, `notification:updated`, `notification:read`
   - Emit events to NotificationCubit

#### 3. **Create Student & Class Cubits**
   - `lib/cubits/student_cubit.dart` - Use StudentService
   - `lib/cubits/class_cubit.dart` - Use ClassService
   - Register in service locator
   - Add to main.dart BlocProviders

#### 4. **Rename Dean Screens to Manager**
   - `dean_home_screen.dart` → `manager_home_screen.dart`
   - `dean_screen.dart` → `manager_screen.dart`
   - Update routes: `/dean` → `/manager`
   - Update all navigation calls

#### 5. **Test with Running Backend**
   - Start backend server
   - Test all authentication flows
   - Verify JWT token persistence
   - Check API logging

---

## Files Modified

1. ✅ `pubspec.yaml` - Added get_it package
2. ✅ `lib/config/service_locator.dart` - NEW FILE (38 lines)
3. ✅ `lib/cubits/user_cubit.dart` - REPLACED (163 lines)
4. ✅ `lib/screens/signup_screen.dart` - 2 edits (signup call + role dropdown)
5. ✅ `lib/main.dart` - Added setupServiceLocator() + checkAuthStatus()

---

## Summary

**What Changed:**
- Mock authentication → Real API authentication
- Local user list → Backend database
- Hardcoded validation → Backend validation
- No persistence → JWT tokens in secure storage
- Manual login on start → Auto-login with saved tokens

**Benefits:**
- ✅ Real authentication with Node.js backend
- ✅ Persistent login (stays logged in after app restart)
- ✅ Secure token storage (flutter_secure_storage)
- ✅ Automatic token injection in all API requests
- ✅ Auto-logout on token expiration
- ✅ Clean architecture with dependency injection
- ✅ Easy to test and maintain

**Zero Errors:** All code compiles successfully! 🎉

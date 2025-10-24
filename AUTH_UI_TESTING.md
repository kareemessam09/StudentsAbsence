# 🔐 Authentication UI Testing Guide

## ✅ Changes Made

### 1. **Fixed Route Navigation** (`lib/main.dart`)
```dart
// Changed route from '/dean' to '/manager'
case '/manager':
  page = const DeanScreen();
  break;
```

### 2. **Auto-detect Platform for API** (`lib/config/api_config.dart`)
```dart
static String get baseUrl {
  // Android emulator uses 10.0.2.2 instead of localhost
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';
  }
  return 'http://localhost:3000/api';
}
```

**Why this is important:**
- Android emulator cannot access `localhost` directly
- `10.0.2.2` is the special IP that routes to your host machine's `localhost`
- iOS simulator can use `localhost` directly
- For physical devices, you'll need your computer's IP address (e.g., `192.168.1.100`)

---

## 🚀 Testing Steps

### Step 1: Start Backend Server

```bash
cd backend
npm start
```

**Expected output:**
```
Server running on port 3000
MongoDB connected successfully
```

**Verify backend is accessible:**
```bash
curl http://localhost:3000/api/auth/login
```

Should return something like: `{"success":false,"message":"Email and password are required"}`

---

### Step 2: Run Flutter App

**For Desktop (macOS/Linux/Windows):**
```bash
flutter run -d macos    # or linux, windows
```

**For iOS Simulator:**
```bash
flutter run -d "iPhone 15 Pro"  # or any iOS simulator
```

**For Android Emulator:**
```bash
# Start emulator first (or use Android Studio)
flutter emulators --launch <emulator_name>

# Then run app
flutter run -d emulator-5554  # or your emulator id
```

---

## 📋 Test Cases

### Test 1: Login with Existing User

**Steps:**
1. App should open to login screen
2. Enter credentials:
   - **Manager:** `manager@school.com` / `password123`
   - **Teacher:** `teacher@school.com` / `password123`
   - **Receptionist:** `receptionist@school.com` / `password123`
3. Click "Login"

**Expected Results:**
- ✅ Loading spinner appears on button
- ✅ All form fields are disabled during loading
- ✅ After successful login, navigate to appropriate screen:
  - Manager → Manager/Dean screen
  - Teacher → Teacher screen
  - Receptionist → Receptionist screen
- ✅ No error messages

**Console logs to check:**
```
┌──────────────────────────────────────────────────────────────
│ POST http://10.0.2.2:3000/api/auth/login
│ Headers:
│   Content-Type: application/json
│ Body:
│   {"email":"manager@school.com","password":"password123"}
├──────────────────────────────────────────────────────────────
│ 200 OK
│ Response:
│   {"success":true,"token":"eyJhbGc...","user":{...}}
└──────────────────────────────────────────────────────────────
```

---

### Test 2: Login with Invalid Credentials

**Steps:**
1. Enter invalid credentials:
   - Email: `wrong@example.com`
   - Password: `wrongpassword`
2. Click "Login"

**Expected Results:**
- ✅ Loading spinner appears briefly
- ✅ Red error snackbar appears at bottom with message: "Invalid credentials" or similar
- ✅ Form remains on login screen
- ✅ Form fields are enabled again after error

**Console logs:**
```
│ 401 Unauthorized
│ Response:
│   {"success":false,"message":"Invalid credentials"}
```

---

### Test 3: Login with Network Error

**Steps:**
1. Stop backend server (`Ctrl+C` in backend terminal)
2. Try to login with any credentials
3. Click "Login"

**Expected Results:**
- ✅ Loading spinner appears
- ✅ Red error snackbar with message like: "Network error" or "Connection refused"
- ✅ User stays on login screen

**How to fix if test fails:**
- Check `lib/config/api_config.dart` has correct URL
- For Android emulator, verify it's using `10.0.2.2:3000`
- For iOS simulator, verify it's using `localhost:3000`
- For physical device, use your computer's IP address

---

### Test 4: Create New Account (Signup)

**Steps:**
1. Click "Sign up" link on login screen
2. Fill in signup form:
   - Name: `Test User`
   - Email: `testuser@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
   - Role: Select `Teacher` or `Receptionist`
3. Click "Create Account"

**Expected Results:**
- ✅ Loading spinner appears on button
- ✅ All fields disabled during loading
- ✅ After success, navigate to appropriate home screen
- ✅ User is automatically logged in (no need to login again)

**Console logs:**
```
│ POST http://10.0.2.2:3000/api/auth/register
│ Body:
│   {
│     "name":"Test User",
│     "email":"testuser@example.com",
│     "password":"password123",
│     "confirmPassword":"password123",
│     "isManager":false
│   }
├──────────────────────────────────────────────────────────────
│ 201 Created
│ Response:
│   {"success":true,"token":"...","user":{...}}
```

---

### Test 5: Signup Validation

**Test 5a: Password Mismatch**
1. Fill signup form
2. Password: `password123`
3. Confirm Password: `different123`
4. Try to submit

**Expected:** 
- ✅ Form validation error: "Passwords do not match"
- ✅ Button stays disabled or validation prevents submission

**Test 5b: Invalid Email**
1. Email: `notanemail`
2. Try to submit

**Expected:**
- ✅ Validation error: "Please enter a valid email"

**Test 5c: Short Password**
1. Password: `123`
2. Try to submit

**Expected:**
- ✅ Validation error about password length (if implemented)

**Test 5d: Duplicate Email**
1. Use email that already exists: `manager@school.com`
2. Fill rest of form correctly
3. Click "Create Account"

**Expected:**
- ✅ Backend returns error: "User already exists" or similar
- ✅ Red error snackbar appears
- ✅ User stays on signup screen

---

### Test 6: Auto-login on App Restart

**Steps:**
1. Login with any user (e.g., `manager@school.com`)
2. Verify you're on the home screen
3. Close the app completely (don't just minimize)
4. Reopen the app

**Expected Results:**
- ✅ App should automatically login
- ✅ You should be taken directly to the home screen (skip login screen)
- ✅ No need to enter credentials again

**How it works:**
- JWT token is saved in `flutter_secure_storage`
- On app start, `main.dart` calls `checkAuthStatus()`
- If token exists, user is automatically authenticated

**To debug:**
```dart
// In lib/cubits/user_cubit.dart, add prints:
Future<void> checkAuthStatus() async {
  final isLoggedIn = await _authService.isLoggedIn();
  print('🔍 Is logged in: $isLoggedIn');
  
  if (isLoggedIn) {
    final user = await _authService.getSavedUser();
    print('👤 Saved user: ${user?.name}');
    if (user != null) {
      emit(UserAuthenticated(user));
    }
  }
}
```

---

### Test 7: Logout and Token Clearing

**Steps:**
1. Login with any user
2. Navigate to profile screen (if available)
3. Click logout button

**Expected Results:**
- ✅ Navigate back to login screen
- ✅ JWT token cleared from secure storage
- ✅ If you restart app now, you should see login screen (not auto-login)

**Console logs:**
```
│ POST http://10.0.2.2:3000/api/auth/logout
│ Headers:
│   Authorization: Bearer eyJhbGc...
```

---

### Test 8: Role-based Navigation

**Steps:**
Test each user role navigates to correct screen:

**Manager:**
- Login: `manager@school.com` / `password123`
- Should navigate to: Manager/Dean screen

**Teacher:**
- Login: `teacher@school.com` / `password123`
- Should navigate to: Teacher screen

**Receptionist:**
- Login: `receptionist@school.com` / `password123`
- Should navigate to: Receptionist screen

**Expected:**
- ✅ Each role goes to its specific home screen
- ✅ Navigation is automatic after login
- ✅ No manual route selection needed

---

## 🐛 Common Issues & Solutions

### Issue 1: "Network Error" or "Connection Refused"

**Symptoms:**
- Can't login/signup
- Error: "Connection refused" or "SocketException"

**Solutions:**

**For Android Emulator:**
```dart
// In lib/config/api_config.dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';  // ✅ Correct
    // NOT: http://localhost:3000/api    // ❌ Wrong
  }
  return 'http://localhost:3000/api';
}
```

**For Physical Android/iOS Device:**
1. Find your computer's IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet "
   
   # Windows
   ipconfig
   ```
2. Update API config:
   ```dart
   return 'http://192.168.1.100:3000/api';  // Use your IP
   ```
3. Make sure phone and computer are on same WiFi network
4. Make sure backend allows connections from your IP

**For iOS Simulator:**
```dart
return 'http://localhost:3000/api';  // ✅ This works on iOS
```

---

### Issue 2: "Invalid token" or Auto-logout

**Symptoms:**
- Login works but immediately logs out
- Error: "Invalid token" or "Unauthorized"

**Causes:**
- Token expired (JWT has expiration time)
- Backend token secret changed
- Clock sync issue between device and server

**Solutions:**
1. Clear app data and login again
2. Check backend JWT settings (expiration time)
3. Make sure system clocks are synchronized

---

### Issue 3: Route Not Found - `/manager` Error

**Symptoms:**
- Login succeeds but navigation fails
- Error: "Could not navigate to /manager"

**Solution:**
- Already fixed! Route is now `/manager` instead of `/dean`
- Verify in `lib/main.dart`:
  ```dart
  case '/manager':
    page = const DeanScreen();
    break;
  ```

---

### Issue 4: "User already exists" on Signup

**Symptoms:**
- Can't create account with specific email

**Cause:**
- Email already registered in database

**Solutions:**
1. Use different email address
2. Or clear backend database:
   ```bash
   cd backend
   npm run seed  # If you have a seed script
   ```

---

### Issue 5: No API Logs in Console

**Symptoms:**
- Can't see API request/response logs
- Hard to debug issues

**Solution:**
- Logs should appear automatically (pretty_dio_logger is configured)
- If not visible, check Flutter DevTools console
- Run with verbose logging:
  ```bash
  flutter run -v
  ```

---

## 🎯 Backend Test Users

If your backend has seed data, you should have these test users:

| Email | Password | Role | Description |
|-------|----------|------|-------------|
| `manager@school.com` | `password123` | Manager | Can view all classes and notifications |
| `teacher@school.com` | `password123` | Teacher | Can manage their classes and send notifications |
| `receptionist@school.com` | `password123` | Receptionist | Can manage students |

**If these don't work:**
1. Check backend database has seed data
2. Run backend seed script if available
3. Or create users manually via signup screen

---

## 📊 Success Checklist

After testing, you should be able to:

- ✅ Login with existing users
- ✅ See loading states during API calls
- ✅ See error messages for invalid credentials
- ✅ Create new accounts via signup
- ✅ Auto-login on app restart (token persistence)
- ✅ Logout and clear tokens
- ✅ Navigate to correct screen based on role
- ✅ See API logs in console (requests/responses)
- ✅ Handle network errors gracefully

---

## 🔍 Debugging Tips

### Check Saved Tokens

Add this to your profile screen or debug panel:

```dart
import '../config/service_locator.dart';
import '../services/auth_service.dart';

// Button to check tokens
ElevatedButton(
  onPressed: () async {
    final authService = getIt<AuthService>();
    final token = await authService.storage.read(key: 'auth_token');
    final userData = await authService.storage.read(key: 'user_data');
    
    print('🔑 Token: ${token?.substring(0, 20)}...');
    print('👤 User data: $userData');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token: ${token != null ? "EXISTS" : "NULL"}')),
    );
  },
  child: const Text('Check Token'),
)
```

### Monitor Cubit State Changes

```dart
// In lib/cubits/user_cubit.dart
@override
void emit(UserState state) {
  print('🔄 UserCubit State Change: ${state.runtimeType}');
  if (state is UserError) {
    print('❌ Error: ${state.message}');
  } else if (state is UserAuthenticated) {
    print('✅ Authenticated: ${state.user.name} (${state.user.email})');
  }
  super.emit(state);
}
```

### Test API Directly

```bash
# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"manager@school.com","password":"password123"}'

# Test register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Test User",
    "email":"test@example.com",
    "password":"password123",
    "confirmPassword":"password123",
    "isManager":false
  }'
```

---

## 🎉 Next Steps

After authentication is working:

1. **Update Profile Feature**
   - Test updating user name/email
   - Test changing password

2. **Create Notification Cubit**
   - Replace RequestCubit with NotificationCubit
   - Use NotificationService API

3. **Add Socket.IO Real-time Updates**
   - Connect on login
   - Listen for notification events
   - Update UI in real-time

4. **Create Student & Class Cubits**
   - StudentCubit using StudentService
   - ClassCubit using ClassService

5. **Rename Dean Screens**
   - dean_screen.dart → manager_screen.dart
   - Update all references

---

## 📝 Files Modified

1. ✅ `lib/main.dart` - Changed `/dean` route to `/manager`
2. ✅ `lib/config/api_config.dart` - Auto-detect Android emulator for correct API URL
3. ✅ `lib/screens/login_screen.dart` - Already has backend integration
4. ✅ `lib/screens/signup_screen.dart` - Already has backend integration
5. ✅ `lib/cubits/user_cubit.dart` - Already uses AuthService

---

## 🎨 UI Features Already Implemented

Both login and signup screens have:
- ✅ Loading states (spinner on button)
- ✅ Form field validation
- ✅ Error handling (red snackbar)
- ✅ Success navigation
- ✅ Disabled fields during loading
- ✅ Smooth animations (FadeIn, FadeInDown, etc.)
- ✅ Responsive design
- ✅ Password visibility toggle

**No UI changes needed - everything is ready to test!** 🎉

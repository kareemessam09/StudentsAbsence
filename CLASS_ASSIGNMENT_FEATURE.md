# Class Assignment Feature for Teacher Signup 📚

## Overview
Updated the signup screen to support class assignment for teachers. The UI is ready, but requires backend changes to be fully functional.

---

## Current State ✅

### What Works Now:
1. ✅ **Role Selection** - Teachers can select "Teacher" role during signup
2. ✅ **"Handle All Classes" Checkbox** - Teachers can opt to manage all classes
3. ✅ **Class Selection UI** - Beautiful interface ready to display classes
4. ✅ **Validation** - Ensures teachers select classes (when available)
5. ✅ **Loading States** - Shows loading indicator while fetching classes
6. ✅ **Empty State** - Informative message when no classes available
7. ✅ **Multiple Selection** - Teachers can select one or more classes

### UI Features:
- 📋 **Checkbox list** of available classes
- 🎨 **Class descriptions** shown as subtitles
- ✨ **Smooth animations** (FadeIn)
- 🔘 **"Handle All Classes"** toggle
- ℹ️ **Info message** explaining class assignment will happen after signup
- ⚠️ **Validation** message if no classes selected

---

## Backend Requirements ⚙️

To make class selection work during signup, the backend needs to support:

### 1. Public Classes Endpoint (Option A)
Make `/api/classes` accessible without authentication for signup page.

**Current Response** (with auth):
```bash
curl http://localhost:3000/api/classes \
  -H "Authorization: Bearer <token>"
```

**Needed Response** (without auth):
```json
{
  "status": "success",
  "data": {
    "classes": [
      {
        "_id": "class123",
        "name": "Class A",
        "description": "Mathematics and Science",
        "teacher": null,
        "students": [],
        "capacity": 30,
        "isActive": true
      }
    ],
    "total": 5
  }
}
```

### 2. Alternative: Public Classes Endpoint (Option B)
Create a new endpoint `/api/classes/public` or `/api/classes/available`:

```javascript
// backend/src/routes/classRoutes.js
router.get('/public', async (req, res) => {
  const classes = await Class.find({ isActive: true })
    .select('name description capacity')
    .sort({ name: 1 });
  
  res.json({
    status: 'success',
    data: { classes }
  });
});
```

### 3. Update Registration Endpoint
Accept `classIds` and `handlesAllClasses` parameters:

**Current Request:**
```json
{
  "name": "Emily Teacher",
  "email": "emily@school.com",
  "password": "password123",
  "confirmPassword": "password123",
  "role": "teacher"
}
```

**Updated Request (with classes):**
```json
{
  "name": "Emily Teacher",
  "email": "emily@school.com",
  "password": "password123",
  "confirmPassword": "password123",
  "role": "teacher",
  "classIds": ["class123", "class456"],  // NEW
  "handlesAllClasses": false              // NEW
}
```

**Backend Changes Needed:**
```javascript
// backend/src/controllers/authController.js
const register = async (req, res) => {
  const { name, email, password, confirmPassword, role, classIds, handlesAllClasses } = req.body;
  
  // Create user
  const user = await User.create({
    name,
    email,
    password,
    role
  });
  
  // If teacher, assign classes
  if (role === 'teacher' && classIds && classIds.length > 0) {
    await Class.updateMany(
      { _id: { $in: classIds } },
      { $set: { teacher: user._id } }
    );
  }
  
  // Or set handlesAllClasses flag
  if (role === 'teacher' && handlesAllClasses) {
    user.handlesAllClasses = true;
    await user.save();
  }
  
  // Return user with token
  // ...
};
```

---

## Frontend Implementation Details

### Files Modified:
1. **lib/screens/signup_screen.dart** - Updated with class selection UI

### Key Changes:

#### 1. Added Imports:
```dart
import '../services/class_service.dart';
import '../config/service_locator.dart';
import '../models/class_model.dart';
```

#### 2. Added State Variables:
```dart
List<ClassModel> _availableClasses = [];
Set<String> _selectedClassIds = {};
bool _handlesAllClasses = false;
bool _isLoadingClasses = false;
final ClassService _classService = getIt<ClassService>();
```

#### 3. Added Fetch Classes Method:
```dart
Future<void> _fetchAvailableClasses() async {
  setState(() {
    _isLoadingClasses = true;
  });

  try {
    final result = await _classService.getAllClasses();
    
    if (result['success']) {
      setState(() {
        _availableClasses = result['classes'] as List<ClassModel>;
        _isLoadingClasses = false;
      });
    }
  } catch (e) {
    setState(() {
      _isLoadingClasses = false;
    });
  }
}
```

#### 4. Updated Signup Handler:
```dart
void _handleSignup() {
  // Validation for teacher class selection
  if (_selectedRole == 'teacher' && 
      !_handlesAllClasses && 
      _availableClasses.isNotEmpty && 
      _selectedClassIds.isEmpty) {
    // Show error
    return;
  }
  
  cubit.signup(
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
    confirmPassword: _confirmPasswordController.text,
    role: _selectedRole,
    // TODO: Add when backend supports:
    // classIds: _selectedClassIds.toList(),
    // handlesAllClasses: _handlesAllClasses,
  );
}
```

#### 5. Updated UI:
- ✅ Loading indicator while fetching classes
- ✅ Empty state with informative message
- ✅ List of classes with checkboxes
- ✅ Class descriptions shown
- ✅ "Handle All Classes" toggle

---

## How to Enable This Feature

### Step 1: Update Backend (Choose One Option)

**Option A:** Make existing endpoint public
```javascript
// Remove auth middleware for GET /api/classes
router.get('/', getAllClasses);  // Remove 'protect' middleware
```

**Option B:** Create new public endpoint
```javascript
// Add to classRoutes.js
router.get('/public', getPublicClasses);
```

### Step 2: Update Registration Endpoint
```javascript
// In authController.js, accept classIds and handlesAllClasses
// Assign classes to teacher during registration
```

### Step 3: Enable Frontend Code
In `lib/screens/signup_screen.dart`:

```dart
@override
void initState() {
  super.initState();
  _fetchAvailableClasses(); // ✅ Uncomment this line
}
```

### Step 4: Update UserCubit and AuthService
Add `classIds` and `handlesAllClasses` parameters to signup methods.

---

## Current Workflow (Without Feature)

1. ✅ User signs up as teacher
2. ✅ Account is created with role="teacher"
3. ℹ️ **Manager manually assigns classes later** via admin panel
4. ℹ️ Message shown: "Classes will be assigned after signup"

---

## Future Workflow (With Feature Enabled)

1. ✅ User selects "Teacher" role
2. ✅ Classes list loads from backend
3. ✅ User selects classes OR checks "Handle All Classes"
4. ✅ User submits signup form
5. ✅ Account created with assigned classes
6. ✅ Teacher can immediately start managing selected classes

---

## Testing Plan

### When Backend is Ready:

1. **Test Public Classes Endpoint:**
```bash
curl http://localhost:3000/api/classes/public
# OR
curl http://localhost:3000/api/classes  # if made public
```

2. **Test Signup with Classes:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Emily Teacher",
    "email": "emily@school.com",
    "password": "password123",
    "confirmPassword": "password123",
    "role": "teacher",
    "classIds": ["class123", "class456"],
    "handlesAllClasses": false
  }'
```

3. **Test in Flutter App:**
   - Run app
   - Click "Sign Up"
   - Select "Teacher" role
   - Verify classes load
   - Select one or more classes
   - Submit form
   - Verify account created with classes assigned

---

## UI States

### 1. Loading State:
```
┌──────────────────────────┐
│  Select Classes:          │
│  ┌────────────────────┐  │
│  │                     │  │
│  │   ⟳ Loading...     │  │
│  │                     │  │
│  └────────────────────┘  │
└──────────────────────────┘
```

### 2. Empty State (Current):
```
┌──────────────────────────┐
│  Select Classes:          │
│  ┌────────────────────┐  │
│  │        ℹ️          │  │
│  │  Classes will be   │  │
│  │  assigned after    │  │
│  │  signup            │  │
│  │                     │  │
│  │  After creating    │  │
│  │  your account, a   │  │
│  │  manager can       │  │
│  │  assign classes    │  │
│  └────────────────────┘  │
└──────────────────────────┘
```

### 3. Loaded State (When Feature Enabled):
```
┌──────────────────────────┐
│  Select Classes:          │
│  ┌────────────────────┐  │
│  │ ☑️ Class A          │  │
│  │    Math & Science   │  │
│  │ ☐ Class B          │  │
│  │    Languages        │  │
│  │ ☑️ Class C          │  │
│  │    Arts             │  │
│  └────────────────────┘  │
└──────────────────────────┘
```

---

## Benefits of This Feature

✅ **Better UX** - Teachers select classes during signup  
✅ **Faster Onboarding** - No waiting for admin to assign classes  
✅ **Self-Service** - Teachers choose their subjects  
✅ **Reduced Admin Work** - Less manual class assignment  
✅ **Clear Expectations** - Teachers know their classes immediately  

---

## Current Limitations

⚠️ **Cannot fetch classes** - Endpoint requires authentication  
⚠️ **Manual assignment needed** - Manager must assign classes after signup  
⚠️ **Extra step required** - Not ideal for user experience  

---

## Summary

The signup screen is **fully prepared** for class assignment feature. The UI is complete with:
- ✅ Class loading
- ✅ Class selection
- ✅ "Handle All Classes" option
- ✅ Validation
- ✅ Loading states
- ✅ Empty states

**To enable:** Update backend to allow public access to classes endpoint and accept `classIds` during registration.

**Current workaround:** Classes are assigned by manager after teacher signup.

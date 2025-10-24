# Backend Route Setup Issue

## Problem
The new `assignTeacherToClass` controller function exists, but the route is returning **403 Forbidden** with the error:

```
Access denied. Insufficient permissions.
at /media/kvreem09/0812F39B12F38BC6/backend/Student-Absence/src/middleware/auth.js:42:9
```

## What's Happening
The frontend is correctly sending requests to:
```
PUT /api/classes/:id/assign-teacher
Authorization: Bearer <teacher_jwt_token>
Body: { "assign": true }
```

But the auth middleware is rejecting the request at line 42 (likely a role check).

## What's Needed

### 1. Add the Route
In your Express router file (likely `routes/class.routes.js` or similar), add:

```javascript
const { protect, restrictTo } = require('../middleware/auth');
const classController = require('../controllers/classController');

// Add this route - allow ONLY teachers to access this endpoint
router.put(
  '/:id/assign-teacher',
  protect,                        // Verify JWT token
  restrictTo('teacher'),          // Only allow teachers
  classController.assignTeacherToClass
);
```

**IMPORTANT**: This route should be accessible **ONLY to teachers**, not managers/admins. The purpose is teacher self-assignment.

### 2. Verify Route Order
Make sure this route is placed **BEFORE** the generic `/:id` route:

```javascript
// ✅ CORRECT ORDER
router.put('/:id/assign-teacher', protect, restrictTo('teacher'), classController.assignTeacherToClass);
router.put('/:id', protect, restrictTo('manager', 'admin'), classController.updateClass);

// ❌ WRONG ORDER - this would never match
router.put('/:id', protect, restrictTo('manager', 'admin'), classController.updateClass);
router.put('/:id/assign-teacher', protect, restrictTo('teacher'), classController.assignTeacherToClass);
```

### 3. Update Auth Middleware (if needed)
If your `restrictTo` middleware doesn't support the `teacher` role, update it:

```javascript
// In auth.js middleware
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(
        new AppError('Access denied. Insufficient permissions.', 403)
      );
    }
    next();
  };
};
```

## Testing

### Test 1: Teacher Can Assign Themselves
```bash
curl -X PUT http://localhost:3000/api/classes/68f92d51207e77586e93e77b/assign-teacher \
  -H "Authorization: Bearer <teacher_token>" \
  -H "Content-Type: application/json" \
  -d '{"assign": true}'
```

**Expected Response**: 200 OK
```json
{
  "status": "success",
  "message": "Successfully assigned to class",
  "data": { "class": { ...classData } }
}
```

### Test 2: Manager/Admin Cannot Use This Endpoint
```bash
curl -X PUT http://localhost:3000/api/classes/68f92d51207e77586e93e77b/assign-teacher \
  -H "Authorization: Bearer <manager_token>" \
  -H "Content-Type: application/json" \
  -d '{"assign": true}'
```

**Expected Response**: 403 Forbidden (this endpoint is teacher-only)

### Test 3: Verify Teacher Token
To confirm the token contains the correct role, decode it:
```bash
# The token in the logs:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4ZmE1OTYzZjhmZWNlYTNjYmVhN2NjZiIsImlhdCI6MTc2MTIzNzM0NywiZXhwIjoxNzYxODQyMTQ3fQ.3lfIKf7qdGKUwilbrKOO_RodL-tAw_kiLAR4LOzxxp0

# Decode the payload (middle part):
# Result: {"id":"68fa5963f8fecea3cbea7ccf","iat":1761237347,"exp":1761842147}
# ⚠️ Missing "role" field in token!
```

**Important**: The JWT token must include the user's `role` field. Update your login response to include it:

```javascript
// In your login/auth controller
const token = jwt.sign(
  { 
    id: user._id,
    role: user.role  // ⭐ Add this!
  },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);
```

## Summary

**Action Items**:
1. ✅ Add route: `PUT /:id/assign-teacher` with `restrictTo('teacher')`
2. ✅ Ensure route is placed before `PUT /:id`
3. ✅ Include `role` field in JWT token payload
4. ✅ Test with actual teacher token

Once these changes are made, the frontend will work without any modifications!

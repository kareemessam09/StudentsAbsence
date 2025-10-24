# Updated API Testing Guide - Actual Backend

Based on **http://localhost:3000/api/docs**

## ⚠️ Important Notes

1. **Registration requires `confirmPassword`** field (not `role`)
2. The backend appears to use different user roles than documented (check backend code)
3. Some endpoints may be waiting for database/email service

## Working Endpoints

### 1. Health Check ✅

```bash
curl http://localhost:3000/health
```

**Response:**
```json
{
  "status": "success",
  "message": "Server is running",
  "timestamp": "2025-10-22T17:45:17.740Z"
}
```

### 2. API Documentation ✅

```bash
curl http://localhost:3000/api/docs
```

## Authentication Endpoints

### Register User

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "confirmPassword": "password123"
  }'
```

**Note:** Role assignment might be done differently (check if default role is set, or if there's an admin panel)

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "...",
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

**Save the token:**
```bash
export TOKEN="<token-from-response>"
```

### Get Current User

```bash
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### Logout

```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer $TOKEN"
```

### Update Password

```bash
curl -X PUT http://localhost:3000/api/auth/update-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "password123",
    "newPassword": "newpassword123"
  }'
```

### Forgot Password

```bash
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com"
  }'
```

### Reset Password

```bash
curl -X PUT http://localhost:3000/api/auth/reset-password/RESET_TOKEN_HERE \
  -H "Content-Type: application/json" \
  -d '{
    "password": "newpassword123"
  }'
```

## User Management Endpoints

### Get All Users (Admin only)

```bash
curl "http://localhost:3000/api/users?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### Get User by ID

```bash
curl http://localhost:3000/api/users/USER_ID_HERE \
  -H "Authorization: Bearer $TOKEN"
```

### Update User

```bash
curl -X PUT http://localhost:3000/api/users/USER_ID_HERE \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "email": "newemail@example.com"
  }'
```

### Delete User (Admin only)

```bash
curl -X DELETE http://localhost:3000/api/users/USER_ID_HERE \
  -H "Authorization: Bearer $TOKEN"
```

### Get My Profile

```bash
curl http://localhost:3000/api/users/profile/me \
  -H "Authorization: Bearer $TOKEN"
```

### Update My Profile

```bash
curl -X PUT http://localhost:3000/api/users/profile/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Name",
    "email": "newemail@example.com",
    "avatar": "https://example.com/avatar.jpg"
  }'
```

## Testing Workflow

### Step 1: Check API Documentation

```bash
# See all available endpoints
curl http://localhost:3000/api/docs | python3 -m json.tool > api_docs.json
```

### Step 2: Register & Login

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "test123456",
    "confirmPassword": "test123456"
  }'

# Login
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123456"
  }')

# Extract token (requires jq)
export TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
echo "Token: $TOKEN"
```

### Step 3: Test Protected Endpoints

```bash
# Get current user
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"

# Get my profile
curl http://localhost:3000/api/users/profile/me \
  -H "Authorization: Bearer $TOKEN"

# Update profile
curl -X PUT http://localhost:3000/api/users/profile/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test User"
  }'
```

## Troubleshooting

### Registration hangs?

**Possible causes:**
1. Database connection issue
2. Email service trying to send verification email
3. Password hashing taking time

**Solution:** Check backend logs for errors

### 401 Unauthorized

- Token expired or invalid
- Token not included in Authorization header
- Wrong format: Must be `Bearer <token>`

### 403 Forbidden

- User doesn't have permission for this endpoint
- Need admin role for certain operations

### Missing Endpoints

**Note:** The /api/docs only shows auth and users endpoints.  
Student, Class, and Notification endpoints might be:
- At different paths
- Not documented
- Not yet implemented

**Check backend routes file for actual available endpoints**

## Next Steps for Flutter Integration

1. **Identify all endpoints**
   - Students: `/api/students/*`
   - Classes: `/api/classes/*`
   - Notifications: `/api/notifications/*`

2. **Understand role system**
   - How are roles assigned? (during registration? by admin?)
   - What are the actual role names? (manager? admin? dean?)

3. **Test complete workflow**
   - Register users with different roles
   - Create students
   - Create classes
   - Send notifications

4. **Document findings**
   - Update models if needed
   - Create API service layer
   - Integrate with Flutter app

---

**Status:** ✅ Health check works, 📝 Need to verify other endpoints

Run backend and check console logs for more information about available routes.

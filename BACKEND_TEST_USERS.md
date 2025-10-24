# Creating Test Users in Backend

Since all demo accounts have been removed, you need to create real users in your backend database.

---

## Option 1: Use the Signup Screen (Easiest)

1. Start the backend:
   ```bash
   cd backend
   npm start
   ```

2. Start the Flutter app:
   ```bash
   flutter run
   ```

3. Click "Sign Up" on the login screen
4. Create accounts for different roles:
   - **Receptionist:** Name: "Sarah Johnson", Email: "sarah@school.com", Password: "password123"
   - **Teacher:** Name: "Emily Brown", Email: "emily@school.com", Password: "password123"
   - **Manager:** Name: "Robert Dean", Email: "robert@school.com", Password: "password123" (check "Register as Manager")

---

## Option 2: Use cURL/Postman (Backend API)

### Create a Receptionist:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sarah Johnson",
    "email": "sarah@school.com",
    "password": "password123",
    "confirmPassword": "password123",
    "isManager": false
  }'
```

### Create a Teacher:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Emily Brown",
    "email": "emily@school.com",
    "password": "password123",
    "confirmPassword": "password123",
    "isManager": false
  }'
```

**Then update the teacher's role in MongoDB:**
```javascript
// In MongoDB Compass or mongo shell:
db.users.updateOne(
  { email: "emily@school.com" },
  { $set: { role: "teacher" } }
)
```

### Create a Manager:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Robert Dean",
    "email": "robert@school.com",
    "password": "password123",
    "confirmPassword": "password123",
    "isManager": true
  }'
```

---

## Option 3: Direct MongoDB Insertion

If you have MongoDB Compass or mongo shell access:

```javascript
// Connect to your database
use school_attendance_db

// Create a receptionist
db.users.insertOne({
  name: "Sarah Johnson",
  email: "sarah@school.com",
  password: "$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIeWU8u7oG", // password123
  role: "receptionist",
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date()
})

// Create a teacher
db.users.insertOne({
  name: "Emily Brown",
  email: "emily@school.com",
  password: "$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIeWU8u7oG", // password123
  role: "teacher",
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date()
})

// Create a manager
db.users.insertOne({
  name: "Robert Dean",
  email: "robert@school.com",
  password: "$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIeWU8u7oG", // password123
  role: "manager",
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date()
})
```

**Note:** The password hash above is for "password123" encrypted with bcrypt (12 rounds)

---

## Verify Backend is Running

```bash
# Test health check
curl http://localhost:3000/api/auth/login

# Should return something like:
# {"status":"fail","error":{...},"message":"Incorrect email or password"}
# This means the backend is working!
```

---

## Test Login After Creating Users

### From Flutter App:
1. Open login screen
2. Enter: `sarah@school.com` / `password123`
3. Click "Login"
4. Should navigate to receptionist home screen

### From cURL:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah@school.com",
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
      "name": "Sarah Johnson",
      "email": "sarah@school.com",
      "role": "receptionist",
      "isActive": true
    }
  }
}
```

---

## Common Issues

### ❌ "Something went wrong"
**Cause:** User doesn't exist in database  
**Solution:** Create the user using one of the methods above

### ❌ "Incorrect email or password"
**Cause:** Wrong credentials  
**Solution:** Double-check email and password match what you created

### ❌ "Network error" / "Connection refused"
**Cause:** Backend not running  
**Solution:** Start backend with `npm start` in backend directory

### ❌ "Cannot connect to MongoDB"
**Cause:** MongoDB not running  
**Solution:** 
- Start MongoDB: `sudo systemctl start mongod` (Linux)
- Or: `brew services start mongodb-community` (Mac)
- Check connection string in backend `.env` file

---

## Recommended Test Users

Create these users for complete testing:

| Role | Name | Email | Password |
|------|------|-------|----------|
| Receptionist | Sarah Johnson | sarah@school.com | password123 |
| Teacher | Emily Brown | emily@school.com | password123 |
| Manager | Robert Dean | robert@school.com | password123 |

**All passwords:** `password123` (for testing only!)

---

## Backend Configuration

Make sure your backend `.env` file has:

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/school_attendance_db
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=7d
NODE_ENV=development
```

---

## Next Steps After Creating Users

1. ✅ Login with receptionist account → Test receptionist features
2. ✅ Login with teacher account → Test teacher features (approve/reject notifications)
3. ✅ Login with manager account → Test manager/dean features
4. ✅ Create classes and students in backend
5. ✅ Test notification flow: receptionist sends → teacher receives → teacher responds
6. ✅ Add Socket.IO for real-time updates

---

**Remember:** The app now uses **100% real backend data**. No more demo accounts or mock data! 🎉

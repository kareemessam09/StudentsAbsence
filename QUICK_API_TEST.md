# Quick Start - Testing Backend API

## Prerequisites

Make sure your backend is running on **http://localhost:3000**

## Option 1: Bash Script (Recommended for Linux)

```bash
# Run the automated test script
./test_api.sh
```

## Option 2: Python Script (Cross-platform)

```bash
# Install requests if needed
pip3 install requests

# Run the test
python3 test_api.py
```

## Option 3: Manual Testing with curl

### 1. Quick Health Check

```bash
curl http://localhost:3000/health
```

### 2. Register Manager

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin Manager",
    "email": "manager@school.com",
    "password": "manager123",
    "role": "manager"
  }'
```

**Save the token from response!**

### 3. Create a Student

```bash
# Replace YOUR_TOKEN_HERE with the token from step 2
curl -X POST http://localhost:3000/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "studentCode": "STU001",
    "nama": "Ahmad Abdullah",
    "enrollmentDate": "2024-09-01"
  }'
```

## Option 4: Postman / Insomnia

1. Import the collection from `API_TESTING_GUIDE.md`
2. Set base URL: `http://localhost:3000/api`
3. Run the requests in order

## Test Results

If successful, you should see:
- ✅ Manager, Teacher, Receptionist registered
- ✅ Student created
- ✅ Class created
- ✅ Notification sent and responded

## Troubleshooting

### Backend not running?

```bash
# Check if port 3000 is in use
lsof -i :3000

# Or check with curl
curl http://localhost:3000/health
```

### Permission denied for test_api.sh?

```bash
chmod +x test_api.sh
```

### jq not installed? (for bash script)

```bash
# Ubuntu/Debian
sudo apt install jq

# Or use Python script instead
python3 test_api.py
```

## What's Next?

After confirming the API works:

1. **Add HTTP Package to Flutter**
   ```yaml
   # In pubspec.yaml
   dependencies:
     dio: ^5.4.0
     socket_io_client: ^2.0.3
   ```

2. **Create API Service**
   - See `lib/services/api_service.dart` (to be created)

3. **Update Cubits**
   - Replace mock data with real API calls

4. **Add Real-time Updates**
   - Integrate Socket.IO for notifications

## Quick Commands Reference

```bash
# Test full workflow
./test_api.sh

# Test with Python
python3 test_api.py

# Manual curl test
curl http://localhost:3000/health

# Check backend logs
# (in your backend terminal window)
```

## API Endpoints Summary

| Endpoint | Method | Auth Required | Role |
|----------|--------|---------------|------|
| `/api/auth/register` | POST | No | - |
| `/api/auth/login` | POST | No | - |
| `/api/students` | GET/POST | Yes | Manager |
| `/api/classes` | GET/POST | Yes | Manager |
| `/api/notifications/request` | POST | Yes | Receptionist |
| `/api/notifications/:id/respond` | PUT | Yes | Teacher |

**Full documentation:** See `API_TESTING_GUIDE.md`

## Status Codes

- **200/201** - Success ✅
- **400** - Bad Request (invalid data) ❌
- **401** - Unauthorized (no/invalid token) ❌
- **403** - Forbidden (wrong role) ❌
- **404** - Not Found ❌
- **500** - Server Error ❌

## Example Response

```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "user": {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Admin Manager",
      "email": "manager@school.com",
      "role": "manager",
      "isActive": true
    }
  }
}
```

---

**Ready to test!** 🚀

Run `./test_api.sh` or `python3 test_api.py` to begin.

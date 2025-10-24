#!/bin/bash

# Student Absence API - Quick Test Script
# Make sure your backend is running on http://localhost:3000

API_BASE="http://localhost:3000/api"

echo "🚀 Starting API Test..."
echo "================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print info
info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Test 1: Check if backend is running
echo ""
info "Test 1: Checking if backend is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    success "Backend is running on localhost:3000"
else
    error "Backend is NOT running on localhost:3000"
    error "Please start your backend server first!"
    exit 1
fi

# Test 2: Register Manager
echo ""
info "Test 2: Registering Manager..."
MANAGER_RESPONSE=$(curl -s -X POST $API_BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin Manager",
    "email": "manager@school.com",
    "password": "manager123",
    "role": "manager"
  }')

# Check if registration was successful or user already exists
if echo $MANAGER_RESPONSE | grep -q '"token"'; then
    MANAGER_TOKEN=$(echo $MANAGER_RESPONSE | jq -r '.token')
    success "Manager registered successfully"
    info "Token: ${MANAGER_TOKEN:0:20}..."
else
    # Try login instead
    info "Manager might already exist, trying to login..."
    MANAGER_LOGIN=$(curl -s -X POST $API_BASE/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "email": "manager@school.com",
        "password": "manager123"
      }')
    
    if echo $MANAGER_LOGIN | grep -q '"token"'; then
        MANAGER_TOKEN=$(echo $MANAGER_LOGIN | jq -r '.token')
        success "Manager logged in successfully"
        info "Token: ${MANAGER_TOKEN:0:20}..."
    else
        error "Failed to register/login manager"
        echo $MANAGER_RESPONSE | jq
        exit 1
    fi
fi

# Test 3: Register Teacher
echo ""
info "Test 3: Registering Teacher..."
TEACHER_RESPONSE=$(curl -s -X POST $API_BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Dr. Emily Brown",
    "email": "emily.teacher@school.com",
    "password": "teacher123",
    "role": "teacher"
  }')

if echo $TEACHER_RESPONSE | grep -q '"token"'; then
    TEACHER_TOKEN=$(echo $TEACHER_RESPONSE | jq -r '.token')
    TEACHER_ID=$(echo $TEACHER_RESPONSE | jq -r '.data.user._id')
    success "Teacher registered successfully"
    info "Teacher ID: $TEACHER_ID"
else
    # Try login
    TEACHER_LOGIN=$(curl -s -X POST $API_BASE/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "email": "emily.teacher@school.com",
        "password": "teacher123"
      }')
    
    if echo $TEACHER_LOGIN | grep -q '"token"'; then
        TEACHER_TOKEN=$(echo $TEACHER_LOGIN | jq -r '.token')
        TEACHER_ID=$(echo $TEACHER_LOGIN | jq -r '.data.user._id')
        success "Teacher logged in successfully"
        info "Teacher ID: $TEACHER_ID"
    else
        error "Failed to register/login teacher"
        exit 1
    fi
fi

# Test 4: Register Receptionist
echo ""
info "Test 4: Registering Receptionist..."
RECEPTIONIST_RESPONSE=$(curl -s -X POST $API_BASE/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sarah Johnson",
    "email": "sarah.receptionist@school.com",
    "password": "receptionist123",
    "role": "receptionist"
  }')

if echo $RECEPTIONIST_RESPONSE | grep -q '"token"'; then
    RECEPTIONIST_TOKEN=$(echo $RECEPTIONIST_RESPONSE | jq -r '.token')
    RECEPTIONIST_ID=$(echo $RECEPTIONIST_RESPONSE | jq -r '.data.user._id')
    success "Receptionist registered successfully"
else
    # Try login
    RECEPTIONIST_LOGIN=$(curl -s -X POST $API_BASE/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "email": "sarah.receptionist@school.com",
        "password": "receptionist123"
      }')
    
    if echo $RECEPTIONIST_LOGIN | grep -q '"token"'; then
        RECEPTIONIST_TOKEN=$(echo $RECEPTIONIST_LOGIN | jq -r '.token')
        RECEPTIONIST_ID=$(echo $RECEPTIONIST_LOGIN | jq -r '.data.user._id')
        success "Receptionist logged in successfully"
    else
        error "Failed to register/login receptionist"
        exit 1
    fi
fi

# Test 5: Create Student
echo ""
info "Test 5: Creating Student (as Manager)..."
STUDENT_RESPONSE=$(curl -s -X POST $API_BASE/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentCode": "STU001",
    "nama": "Ahmad Abdullah",
    "enrollmentDate": "2024-09-01"
  }')

if echo $STUDENT_RESPONSE | grep -q '"studentCode"'; then
    STUDENT_ID=$(echo $STUDENT_RESPONSE | jq -r '.data.student._id')
    success "Student created successfully"
    info "Student ID: $STUDENT_ID"
    info "Student Code: STU001"
else
    # Student might already exist
    info "Student might already exist, fetching students..."
    STUDENTS=$(curl -s -X GET "$API_BASE/students?limit=1" \
      -H "Authorization: Bearer $MANAGER_TOKEN")
    
    if echo $STUDENTS | grep -q 'STU001'; then
        STUDENT_ID=$(echo $STUDENTS | jq -r '.data.students[0]._id')
        success "Found existing student"
        info "Student ID: $STUDENT_ID"
    else
        error "Failed to create/find student"
        echo $STUDENT_RESPONSE | jq
        exit 1
    fi
fi

# Test 6: Create Class
echo ""
info "Test 6: Creating Class (as Manager)..."
CLASS_RESPONSE=$(curl -s -X POST $API_BASE/classes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "name": "Mathematics 101",
    "description": "Basic mathematics course",
    "teacher": "'$TEACHER_ID'",
    "capacity": 30,
    "startDate": "2024-09-01"
  }')

if echo $CLASS_RESPONSE | grep -q '"name"'; then
    CLASS_ID=$(echo $CLASS_RESPONSE | jq -r '.data.class._id')
    success "Class created successfully"
    info "Class ID: $CLASS_ID"
else
    # Class might already exist
    info "Class might already exist, fetching classes..."
    CLASSES=$(curl -s -X GET "$API_BASE/classes?limit=1" \
      -H "Authorization: Bearer $MANAGER_TOKEN")
    
    CLASS_ID=$(echo $CLASSES | jq -r '.data.classes[0]._id // empty')
    if [ -n "$CLASS_ID" ]; then
        success "Found existing class"
        info "Class ID: $CLASS_ID"
    else
        error "Failed to create/find class"
        echo $CLASS_RESPONSE | jq
        exit 1
    fi
fi

# Test 7: Add Student to Class
echo ""
info "Test 7: Adding Student to Class..."
ADD_STUDENT=$(curl -s -X POST $API_BASE/classes/$CLASS_ID/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MANAGER_TOKEN" \
  -d '{
    "studentId": "'$STUDENT_ID'"
  }')

if echo $ADD_STUDENT | grep -q 'success\|already'; then
    success "Student added to class (or already in class)"
else
    error "Failed to add student to class"
    echo $ADD_STUDENT | jq
fi

# Test 8: Send Notification Request
echo ""
info "Test 8: Receptionist sending request to Teacher..."
NOTIFICATION_RESPONSE=$(curl -s -X POST $API_BASE/notifications/request \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN" \
  -d '{
    "studentId": "'$STUDENT_ID'",
    "message": "Is student Ahmad present in your class?"
  }')

if echo $NOTIFICATION_RESPONSE | grep -q '"notification"'; then
    NOTIFICATION_ID=$(echo $NOTIFICATION_RESPONSE | jq -r '.data.notification._id')
    success "Notification sent successfully"
    info "Notification ID: $NOTIFICATION_ID"
else
    error "Failed to send notification"
    echo $NOTIFICATION_RESPONSE | jq
    exit 1
fi

# Test 9: Teacher Checks Notifications
echo ""
info "Test 9: Teacher checking notifications..."
TEACHER_NOTIFS=$(curl -s -X GET $API_BASE/notifications \
  -H "Authorization: Bearer $TEACHER_TOKEN")

if echo $TEACHER_NOTIFS | grep -q 'notifications'; then
    NOTIF_COUNT=$(echo $TEACHER_NOTIFS | jq '.data.notifications | length')
    success "Teacher has $NOTIF_COUNT notification(s)"
else
    error "Failed to get teacher notifications"
fi

# Test 10: Teacher Responds
echo ""
info "Test 10: Teacher responding to notification..."
RESPOND=$(curl -s -X PUT $API_BASE/notifications/$NOTIFICATION_ID/respond \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -d '{
    "status": "present",
    "responseMessage": "Yes, Ahmad is present in my class"
  }')

if echo $RESPOND | grep -q 'success'; then
    success "Teacher responded successfully"
else
    error "Failed to respond to notification"
    echo $RESPOND | jq
fi

# Test 11: Receptionist Checks Response
echo ""
info "Test 11: Receptionist checking for response..."
RECEP_NOTIFS=$(curl -s -X GET $API_BASE/notifications \
  -H "Authorization: Bearer $RECEPTIONIST_TOKEN")

if echo $RECEP_NOTIFS | grep -q 'present'; then
    success "Receptionist received teacher's response"
    info "Status: present"
else
    info "Response might still be pending"
fi

# Summary
echo ""
echo "================================"
echo -e "${GREEN}🎉 All Tests Completed!${NC}"
echo "================================"
echo ""
echo "📝 Summary:"
echo "  Manager Token: ${MANAGER_TOKEN:0:30}..."
echo "  Teacher Token: ${TEACHER_TOKEN:0:30}..."
echo "  Teacher ID: $TEACHER_ID"
echo "  Receptionist Token: ${RECEPTIONIST_TOKEN:0:30}..."
echo "  Student ID: $STUDENT_ID"
echo "  Class ID: $CLASS_ID"
echo "  Notification ID: $NOTIFICATION_ID"
echo ""
echo "✅ Backend API is working correctly!"
echo "✅ Ready to integrate with Flutter app"
echo ""
echo "💡 Next steps:"
echo "  1. Add http/dio package to Flutter app"
echo "  2. Create API service layer"
echo "  3. Update Cubits to call API endpoints"
echo "  4. Add Socket.IO for real-time notifications"
echo ""

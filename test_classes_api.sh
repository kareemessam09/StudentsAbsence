#!/bin/bash

# Test Classes API Endpoint
# This script tests the classes endpoint with authentication

echo "===== Testing Classes API ====="
echo ""

# Backend URL
BACKEND_URL="http://localhost:3000/api"

# Step 1: Login to get token
echo "1. Logging in to get authentication token..."
LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teacher@test.com",
    "password": "password123"
  }')

echo "Login Response:"
echo "$LOGIN_RESPONSE" | jq '.' 2>/dev/null || echo "$LOGIN_RESPONSE"
echo ""

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token' 2>/dev/null)

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token. Make sure teacher@test.com exists."
  echo "Creating test teacher account..."
  
  SIGNUP_RESPONSE=$(curl -s -X POST "$BACKEND_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Test Teacher",
      "email": "teacher@test.com",
      "password": "password123",
      "confirmPassword": "password123",
      "role": "teacher"
    }')
  
  echo "Signup Response:"
  echo "$SIGNUP_RESPONSE" | jq '.' 2>/dev/null || echo "$SIGNUP_RESPONSE"
  echo ""
  
  # Try login again
  LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "teacher@test.com",
      "password": "password123"
    }')
  
  TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token' 2>/dev/null)
fi

echo "Token: $TOKEN"
echo ""

# Step 2: Get all classes
echo "2. Fetching all classes..."
CLASSES_RESPONSE=$(curl -s -X GET "$BACKEND_URL/classes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo "Classes Response:"
echo "$CLASSES_RESPONSE" | jq '.' 2>/dev/null || echo "$CLASSES_RESPONSE"
echo ""

# Count classes
CLASS_COUNT=$(echo "$CLASSES_RESPONSE" | jq '.classes | length' 2>/dev/null)

if [ "$CLASS_COUNT" = "0" ] || [ "$CLASS_COUNT" = "null" ]; then
  echo "⚠️  No classes found in database!"
  echo ""
  echo "You need to create some classes first."
  echo "Would you like to create a test class? (y/n)"
  read -r CREATE_CLASS
  
  if [ "$CREATE_CLASS" = "y" ] || [ "$CREATE_CLASS" = "Y" ]; then
    echo ""
    echo "Creating test classes..."
    
    # Create Class A
    curl -s -X POST "$BACKEND_URL/classes" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Class A",
        "description": "Mathematics and Science",
        "capacity": 30
      }' | jq '.' 2>/dev/null || echo "Created Class A"
    
    echo ""
    
    # Create Class B
    curl -s -X POST "$BACKEND_URL/classes" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Class B",
        "description": "Languages and Arts",
        "capacity": 25
      }' | jq '.' 2>/dev/null || echo "Created Class B"
    
    echo ""
    
    # Create Class C
    curl -s -X POST "$BACKEND_URL/classes" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Class C",
        "description": "Physical Education",
        "capacity": 35
      }' | jq '.' 2>/dev/null || echo "Created Class C"
    
    echo ""
    echo "✅ Test classes created!"
    echo ""
    echo "Fetching classes again..."
    CLASSES_RESPONSE=$(curl -s -X GET "$BACKEND_URL/classes" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json")
    
    echo "$CLASSES_RESPONSE" | jq '.' 2>/dev/null || echo "$CLASSES_RESPONSE"
  fi
else
  echo "✅ Found $CLASS_COUNT classes"
fi

echo ""
echo "===== Test Complete ====="

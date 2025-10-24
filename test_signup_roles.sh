#!/bin/bash

# Test signup with all three roles

echo "🧪 Testing Signup with All Roles"
echo "=================================="
echo ""

# Generate unique timestamp for emails
TIMESTAMP=$(date +%s)

echo "1️⃣  Testing RECEPTIONIST role..."
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Sarah Receptionist\",
    \"email\": \"sarah.receptionist${TIMESTAMP}@school.com\",
    \"password\": \"password123\",
    \"confirmPassword\": \"password123\",
    \"role\": \"receptionist\"
  }" | python3 -m json.tool

echo -e "\n\n2️⃣  Testing TEACHER role..."
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Emily Teacher\",
    \"email\": \"emily.teacher${TIMESTAMP}@school.com\",
    \"password\": \"password123\",
    \"confirmPassword\": \"password123\",
    \"role\": \"teacher\"
  }" | python3 -m json.tool

echo -e "\n\n3️⃣  Testing MANAGER role..."
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Robert Manager\",
    \"email\": \"robert.manager${TIMESTAMP}@school.com\",
    \"password\": \"password123\",
    \"confirmPassword\": \"password123\",
    \"role\": \"manager\"
  }" | python3 -m json.tool

echo -e "\n\n✅ All tests completed!"

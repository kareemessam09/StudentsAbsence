#!/bin/bash

# Simple API Test - No dependencies required
API_BASE="http://localhost:3000/api"

echo "🚀 Testing Student Absence API"
echo "================================"
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Backend Health..."
curl -s http://localhost:3000/health
echo ""
echo ""

# Test 2: Register Manager
echo "2️⃣  Registering Manager..."
curl -X POST "$API_BASE/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin Manager",
    "email": "manager@school.com",
    "password": "manager123",
    "role": "manager"
  }'
echo ""
echo ""

# Test 3: Login Manager
echo "3️⃣  Logging in as Manager..."
curl -X POST "$API_BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "manager@school.com",
    "password": "manager123"
  }'
echo ""
echo ""

# Test 4: Register Teacher
echo "4️⃣  Registering Teacher..."
curl -X POST "$API_BASE/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Dr. Emily Brown",
    "email": "emily.teacher@school.com",
    "password": "teacher123",
    "role": "teacher"
  }'
echo ""
echo ""

# Test 5: Register Receptionist
echo "5️⃣  Registering Receptionist..."
curl -X POST "$API_BASE/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sarah Johnson",
    "email": "sarah.receptionist@school.com",
    "password": "receptionist123",
    "role": "receptionist"
  }'
echo ""
echo ""

echo "================================"
echo "✅ Basic tests completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Copy the tokens from the responses above"
echo "  2. Use them to test protected endpoints"
echo "  3. See API_TESTING_GUIDE.md for detailed examples"
echo ""
echo "Or run: python3 test_api.py (recommended)"
echo ""

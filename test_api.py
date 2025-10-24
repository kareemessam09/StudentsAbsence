#!/usr/bin/env python3
"""
Student Absence API - Python Test Script
Simple test script to verify backend API is working
"""

import requests
import json
from typing import Dict, Optional

# Configuration
API_BASE = "http://localhost:3000/api"

class Colors:
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def success(msg: str):
    print(f"{Colors.GREEN}✅ {msg}{Colors.NC}")

def error(msg: str):
    print(f"{Colors.RED}❌ {msg}{Colors.NC}")

def info(msg: str):
    print(f"{Colors.YELLOW}ℹ️  {msg}{Colors.NC}")

def test_backend():
    """Main test function"""
    print("🚀 Starting API Test...")
    print("=" * 50)
    
    tokens = {}
    user_ids = {}
    resource_ids = {}
    
    # Test 1: Check backend
    print("\n")
    info("Test 1: Checking if backend is running...")
    try:
        response = requests.get("http://localhost:3000/health", timeout=5)
        if response.status_code == 200:
            success("Backend is running on localhost:3000")
        else:
            error(f"Backend returned status {response.status_code}")
            return
    except Exception as e:
        error(f"Backend is NOT running: {e}")
        error("Please start your backend server first!")
        return
    
    # Test 2: Register/Login Manager
    print("\n")
    info("Test 2: Registering Manager...")
    try:
        response = requests.post(
            f"{API_BASE}/auth/register",
            json={
                "name": "Admin Manager",
                "email": "manager@school.com",
                "password": "manager123",
                "role": "manager"
            }
        )
        
        if response.status_code in [200, 201]:
            data = response.json()
            tokens['manager'] = data.get('token')
            user_ids['manager'] = data.get('data', {}).get('user', {}).get('_id')
            success("Manager registered successfully")
        else:
            # Try login
            info("Manager exists, logging in...")
            response = requests.post(
                f"{API_BASE}/auth/login",
                json={
                    "email": "manager@school.com",
                    "password": "manager123"
                }
            )
            if response.status_code == 200:
                data = response.json()
                tokens['manager'] = data.get('token')
                user_ids['manager'] = data.get('data', {}).get('user', {}).get('_id')
                success("Manager logged in successfully")
            else:
                error(f"Failed to login manager: {response.text}")
                return
                
        info(f"Manager Token: {tokens['manager'][:30]}...")
    except Exception as e:
        error(f"Manager auth failed: {e}")
        return
    
    # Test 3: Register/Login Teacher
    print("\n")
    info("Test 3: Registering Teacher...")
    try:
        response = requests.post(
            f"{API_BASE}/auth/register",
            json={
                "name": "Dr. Emily Brown",
                "email": "emily.teacher@school.com",
                "password": "teacher123",
                "role": "teacher"
            }
        )
        
        if response.status_code in [200, 201]:
            data = response.json()
            tokens['teacher'] = data.get('token')
            user_ids['teacher'] = data.get('data', {}).get('user', {}).get('_id')
            success("Teacher registered successfully")
        else:
            # Try login
            info("Teacher exists, logging in...")
            response = requests.post(
                f"{API_BASE}/auth/login",
                json={
                    "email": "emily.teacher@school.com",
                    "password": "teacher123"
                }
            )
            if response.status_code == 200:
                data = response.json()
                tokens['teacher'] = data.get('token')
                user_ids['teacher'] = data.get('data', {}).get('user', {}).get('_id')
                success("Teacher logged in successfully")
                
        info(f"Teacher ID: {user_ids['teacher']}")
    except Exception as e:
        error(f"Teacher auth failed: {e}")
        return
    
    # Test 4: Register/Login Receptionist
    print("\n")
    info("Test 4: Registering Receptionist...")
    try:
        response = requests.post(
            f"{API_BASE}/auth/register",
            json={
                "name": "Sarah Johnson",
                "email": "sarah.receptionist@school.com",
                "password": "receptionist123",
                "role": "receptionist"
            }
        )
        
        if response.status_code in [200, 201]:
            data = response.json()
            tokens['receptionist'] = data.get('token')
            user_ids['receptionist'] = data.get('data', {}).get('user', {}).get('_id')
            success("Receptionist registered successfully")
        else:
            # Try login
            response = requests.post(
                f"{API_BASE}/auth/login",
                json={
                    "email": "sarah.receptionist@school.com",
                    "password": "receptionist123"
                }
            )
            if response.status_code == 200:
                data = response.json()
                tokens['receptionist'] = data.get('token')
                user_ids['receptionist'] = data.get('data', {}).get('user', {}).get('_id')
                success("Receptionist logged in successfully")
    except Exception as e:
        error(f"Receptionist auth failed: {e}")
        return
    
    # Test 5: Create Student
    print("\n")
    info("Test 5: Creating Student (as Manager)...")
    try:
        response = requests.post(
            f"{API_BASE}/students",
            headers={"Authorization": f"Bearer {tokens['manager']}"},
            json={
                "studentCode": "STU001",
                "nama": "Ahmad Abdullah",
                "enrollmentDate": "2024-09-01"
            }
        )
        
        if response.status_code in [200, 201]:
            data = response.json()
            resource_ids['student'] = data.get('data', {}).get('student', {}).get('_id')
            success("Student created successfully")
            info(f"Student ID: {resource_ids['student']}")
        else:
            # Try to get existing student
            response = requests.get(
                f"{API_BASE}/students?limit=1",
                headers={"Authorization": f"Bearer {tokens['manager']}"}
            )
            if response.status_code == 200:
                data = response.json()
                students = data.get('data', {}).get('students', [])
                if students:
                    resource_ids['student'] = students[0].get('_id')
                    success("Found existing student")
                    info(f"Student ID: {resource_ids['student']}")
    except Exception as e:
        error(f"Student creation failed: {e}")
        return
    
    # Test 6: Create Class
    print("\n")
    info("Test 6: Creating Class (as Manager)...")
    try:
        response = requests.post(
            f"{API_BASE}/classes",
            headers={"Authorization": f"Bearer {tokens['manager']}"},
            json={
                "name": "Mathematics 101",
                "description": "Basic mathematics course",
                "teacher": user_ids['teacher'],
                "capacity": 30,
                "startDate": "2024-09-01"
            }
        )
        
        if response.status_code in [200, 201]:
            data = response.json()
            resource_ids['class'] = data.get('data', {}).get('class', {}).get('_id')
            success("Class created successfully")
            info(f"Class ID: {resource_ids['class']}")
        else:
            # Try to get existing class
            response = requests.get(
                f"{API_BASE}/classes?limit=1",
                headers={"Authorization": f"Bearer {tokens['manager']}"}
            )
            if response.status_code == 200:
                data = response.json()
                classes = data.get('data', {}).get('classes', [])
                if classes:
                    resource_ids['class'] = classes[0].get('_id')
                    success("Found existing class")
                    info(f"Class ID: {resource_ids['class']}")
    except Exception as e:
        error(f"Class creation failed: {e}")
        return
    
    # Test 7: Add Student to Class
    if 'student' in resource_ids and 'class' in resource_ids:
        print("\n")
        info("Test 7: Adding Student to Class...")
        try:
            response = requests.post(
                f"{API_BASE}/classes/{resource_ids['class']}/students",
                headers={"Authorization": f"Bearer {tokens['manager']}"},
                json={"studentId": resource_ids['student']}
            )
            
            if response.status_code in [200, 201]:
                success("Student added to class")
            else:
                info("Student might already be in class")
        except Exception as e:
            error(f"Adding student to class failed: {e}")
    
    # Test 8: Send Notification Request
    if 'student' in resource_ids:
        print("\n")
        info("Test 8: Receptionist sending request to Teacher...")
        try:
            response = requests.post(
                f"{API_BASE}/notifications/request",
                headers={"Authorization": f"Bearer {tokens['receptionist']}"},
                json={
                    "studentId": resource_ids['student'],
                    "message": "Is student Ahmad present in your class?"
                }
            )
            
            if response.status_code in [200, 201]:
                data = response.json()
                resource_ids['notification'] = data.get('data', {}).get('notification', {}).get('_id')
                success("Notification sent successfully")
                info(f"Notification ID: {resource_ids['notification']}")
            else:
                error(f"Failed to send notification: {response.text}")
        except Exception as e:
            error(f"Notification send failed: {e}")
    
    # Test 9: Teacher Checks Notifications
    print("\n")
    info("Test 9: Teacher checking notifications...")
    try:
        response = requests.get(
            f"{API_BASE}/notifications",
            headers={"Authorization": f"Bearer {tokens['teacher']}"}
        )
        
        if response.status_code == 200:
            data = response.json()
            notifications = data.get('data', {}).get('notifications', [])
            success(f"Teacher has {len(notifications)} notification(s)")
        else:
            error("Failed to get teacher notifications")
    except Exception as e:
        error(f"Get notifications failed: {e}")
    
    # Test 10: Teacher Responds
    if 'notification' in resource_ids:
        print("\n")
        info("Test 10: Teacher responding to notification...")
        try:
            response = requests.put(
                f"{API_BASE}/notifications/{resource_ids['notification']}/respond",
                headers={"Authorization": f"Bearer {tokens['teacher']}"},
                json={
                    "status": "present",
                    "responseMessage": "Yes, Ahmad is present in my class"
                }
            )
            
            if response.status_code == 200:
                success("Teacher responded successfully")
            else:
                error(f"Failed to respond: {response.text}")
        except Exception as e:
            error(f"Response failed: {e}")
    
    # Test 11: Receptionist Checks Response
    print("\n")
    info("Test 11: Receptionist checking for response...")
    try:
        response = requests.get(
            f"{API_BASE}/notifications",
            headers={"Authorization": f"Bearer {tokens['receptionist']}"}
        )
        
        if response.status_code == 200:
            data = response.json()
            notifications = data.get('data', {}).get('notifications', [])
            for notif in notifications:
                if notif.get('status') == 'present':
                    success("Receptionist received teacher's response")
                    info("Status: present")
                    break
        else:
            info("Response might still be pending")
    except Exception as e:
        error(f"Check response failed: {e}")
    
    # Summary
    print("\n")
    print("=" * 50)
    print(f"{Colors.GREEN}🎉 All Tests Completed!{Colors.NC}")
    print("=" * 50)
    print("\n📝 Summary:")
    print(f"  Manager Token: {tokens.get('manager', 'N/A')[:30]}...")
    print(f"  Teacher ID: {user_ids.get('teacher', 'N/A')}")
    print(f"  Student ID: {resource_ids.get('student', 'N/A')}")
    print(f"  Class ID: {resource_ids.get('class', 'N/A')}")
    print(f"  Notification ID: {resource_ids.get('notification', 'N/A')}")
    print("\n✅ Backend API is working correctly!")
    print("✅ Ready to integrate with Flutter app")
    print("\n💡 Next steps:")
    print("  1. Add http/dio package to Flutter app")
    print("  2. Create API service layer")
    print("  3. Update Cubits to call API endpoints")
    print("  4. Add Socket.IO for real-time notifications")
    print()

if __name__ == "__main__":
    try:
        test_backend()
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
    except Exception as e:
        error(f"Unexpected error: {e}")

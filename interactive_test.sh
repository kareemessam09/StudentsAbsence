#!/bin/bash

# Interactive API Tester for Student Absence System
# Works with actual backend at localhost:3000

API_BASE="http://localhost:3000/api"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Student Absence API - Quick Tester   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check backend
echo -e "${YELLOW}Checking backend...${NC}"
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is running${NC}"
else
    echo -e "${RED}❌ Backend is NOT running${NC}"
    echo ""
    echo "Please start your backend server first!"
    exit 1
fi

echo ""
echo -e "${BLUE}Available Tests:${NC}"
echo "1. View API Documentation"
echo "2. Register a new user"
echo "3. Login"
echo "4. Get current user (requires token)"
echo "5. Get my profile (requires token)"
echo "6. Update profile (requires token)"
echo "7. Exit"
echo ""

# Function to save token
save_token() {
    echo "$1" > .api_token
    echo -e "${GREEN}Token saved to .api_token${NC}"
}

# Function to load token
load_token() {
    if [ -f .api_token ]; then
        cat .api_token
    else
        echo ""
    fi
}

while true; do
    echo -e "${YELLOW}Select an option (1-7):${NC} "
    read -r choice
    
    case $choice in
        1)
            echo ""
            echo -e "${BLUE}📚 Fetching API Documentation...${NC}"
            curl -s http://localhost:3000/api/docs | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3000/api/docs
            echo ""
            ;;
        2)
            echo ""
            echo -e "${BLUE}📝 Register New User${NC}"
            echo -n "Name: "
            read -r name
            echo -n "Email: "
            read -r email
            echo -n "Password: "
            read -rs password
            echo ""
            echo -n "Confirm Password: "
            read -rs confirm_password
            echo ""
            echo ""
            
            echo -e "${YELLOW}Registering...${NC}"
            RESPONSE=$(curl -s -X POST "$API_BASE/auth/register" \
              -H "Content-Type: application/json" \
              -d "{
                \"name\": \"$name\",
                \"email\": \"$email\",
                \"password\": \"$password\",
                \"confirmPassword\": \"$confirm_password\"
              }")
            
            echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
            
            # Try to extract and save token
            TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
            if [ -n "$TOKEN" ]; then
                save_token "$TOKEN"
            fi
            echo ""
            ;;
        3)
            echo ""
            echo -e "${BLUE}🔐 Login${NC}"
            echo -n "Email: "
            read -r email
            echo -n "Password: "
            read -rs password
            echo ""
            echo ""
            
            echo -e "${YELLOW}Logging in...${NC}"
            RESPONSE=$(curl -s -X POST "$API_BASE/auth/login" \
              -H "Content-Type: application/json" \
              -d "{
                \"email\": \"$email\",
                \"password\": \"$password\"
              }")
            
            echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
            
            # Try to extract and save token
            TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
            if [ -n "$TOKEN" ]; then
                save_token "$TOKEN"
            fi
            echo ""
            ;;
        4)
            echo ""
            TOKEN=$(load_token)
            if [ -z "$TOKEN" ]; then
                echo -e "${RED}❌ No token found. Please login first.${NC}"
            else
                echo -e "${BLUE}👤 Getting Current User...${NC}"
                curl -s "$API_BASE/auth/me" \
                  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || \
                curl -s "$API_BASE/auth/me" \
                  -H "Authorization: Bearer $TOKEN"
            fi
            echo ""
            ;;
        5)
            echo ""
            TOKEN=$(load_token)
            if [ -z "$TOKEN" ]; then
                echo -e "${RED}❌ No token found. Please login first.${NC}"
            else
                echo -e "${BLUE}📋 Getting Profile...${NC}"
                curl -s "$API_BASE/users/profile/me" \
                  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || \
                curl -s "$API_BASE/users/profile/me" \
                  -H "Authorization: Bearer $TOKEN"
            fi
            echo ""
            ;;
        6)
            echo ""
            TOKEN=$(load_token)
            if [ -z "$TOKEN" ]; then
                echo -e "${RED}❌ No token found. Please login first.${NC}"
            else
                echo -e "${BLUE}✏️  Update Profile${NC}"
                echo -n "New Name (press Enter to skip): "
                read -r name
                echo -n "New Email (press Enter to skip): "
                read -r email
                
                # Build JSON
                JSON="{"
                FIELDS=""
                [ -n "$name" ] && FIELDS="\"name\": \"$name\""
                [ -n "$email" ] && [ -n "$FIELDS" ] && FIELDS="$FIELDS, "
                [ -n "$email" ] && FIELDS="${FIELDS}\"email\": \"$email\""
                JSON="${JSON}${FIELDS}}"
                
                if [ "$FIELDS" != "" ]; then
                    echo ""
                    echo -e "${YELLOW}Updating...${NC}"
                    curl -s -X PUT "$API_BASE/users/profile/me" \
                      -H "Authorization: Bearer $TOKEN" \
                      -H "Content-Type: application/json" \
                      -d "$JSON" | python3 -m json.tool 2>/dev/null || \
                    curl -s -X PUT "$API_BASE/users/profile/me" \
                      -H "Authorization: Bearer $TOKEN" \
                      -H "Content-Type: application/json" \
                      -d "$JSON"
                else
                    echo -e "${YELLOW}No changes made${NC}"
                fi
            fi
            echo ""
            ;;
        7)
            echo ""
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please choose 1-7.${NC}"
            ;;
    esac
done

# Dean Dashboard Feature

## Overview
The Dean role provides administrative oversight with a comprehensive dashboard showing attendance statistics across all classes.

## 🎯 Purpose
The Dean dashboard allows school administrators to:
- Monitor overall attendance across all classes
- View real-time statistics for pending, accepted, and not found students
- Analyze class-wise breakdown of attendance data
- Track attendance rates by class
- Get a bird's-eye view of the attendance system

---

## 👤 Dean User

### Demo Account
- **Email**: robert.dean@school.com
- **Password**: password123
- **Name**: Dr. Robert Dean
- **User ID**: 6

### Permissions
- ✅ View all attendance requests (all classes)
- ✅ See aggregated statistics
- ✅ Monitor class-wise performance
- ✅ Access profile settings
- ❌ Cannot create requests (receptionist only)
- ❌ Cannot handle requests (teacher only)

---

## 📊 Dashboard Features

### 1. **Overall Statistics Section**

Four main counters displayed as cards:

#### **Total Requests**
- Icon: 📋 Clipboard List
- Color: Blue
- Shows: Total number of all attendance requests
- Includes: All statuses (pending, accepted, not found)

#### **Pending**
- Icon: ⏰ Clock
- Color: Orange
- Shows: Requests awaiting teacher response
- Real-time: Updates when teachers respond

#### **Accepted**
- Icon: ✅ Check Circle
- Color: Green
- Shows: Students confirmed present in class
- Indicates: Successful attendance confirmations

#### **Not Found**
- Icon: ❌ X Circle
- Color: Red
- Shows: Students confirmed absent
- Indicates: Students not in class

---

### 2. **Class-wise Breakdown Section**

Detailed statistics for each class:

#### **Class Card Components**

**Header:**
- Class icon (👨‍🏫 Chalkboard User)
- Class name (Class A, B, C, etc.)
- Total requests badge

**Attendance Rate:**
- Progress bar showing percentage
- Calculation: (Accepted / Total) × 100%
- Visual indicator of class performance

**Mini Statistics:**
- Pending count (🟠 Orange)
- Accepted count (🟢 Green)
- Not Found count (🔴 Red)

---

## 🎨 UI/UX Design

### **Welcome Banner**
- Gradient background (primary to secondary)
- Chart line icon
- Personalized greeting: "Welcome, Dr. Robert Dean"
- Subtitle: "Attendance Overview"

### **Color Scheme**
- **Blue**: Total requests, primary actions
- **Orange**: Pending/awaiting items
- **Green**: Successful/accepted items
- **Red**: Not found/absent items

### **Animations**
- **FadeInDown**: Welcome banner (600ms)
- **FadeInLeft**: Section headers (600ms)
- **FadeInUp**: Stat cards (staggered 200-300ms)
- **FadeInUp**: Class cards (staggered 500ms + 100ms per card)

### **Layout**
- Pull-to-refresh enabled
- Scrollable content
- Responsive card grid
- Proper spacing and padding
- Material 3 design language

---

## 📈 Statistics Calculation

### **Overall Stats**
```dart
Total Requests = All requests count
Total Pending = Requests with status "pending"
Total Accepted = Requests with status "accepted"
Total Not Found = Requests with status "not_found"
```

### **Class-wise Stats**
For each class:
```dart
Total = All requests for that class
Pending = Class requests with status "pending"
Accepted = Class requests with status "accepted"
Not Found = Class requests with status "not_found"
Attendance Rate = (Accepted / Total) × 100%
```

---

## 🔄 User Flow

### **Login as Dean**
1. Open app → Login screen
2. Enter: robert.dean@school.com / password123
3. Or tap "Dean" demo account
4. System authenticates
5. Navigate to Dean Dashboard

### **View Statistics**
1. Dashboard loads automatically
2. See overall statistics at top
3. Scroll to view class-wise breakdown
4. Pull down to refresh data
5. Statistics update in real-time

### **Navigate to Profile**
1. Tap person icon in AppBar
2. View/edit profile information
3. Logout when needed

---

## 🏗️ Technical Implementation

### **New Files Created**

#### `dean_screen.dart`
- Wrapper screen for dean role
- Routes to DeanHomeScreen

#### `dean_home_screen.dart`
- Main dashboard implementation
- Statistics calculation logic
- UI components and layouts

### **Updated Files**

#### `user_model.dart`
- Added `isDean` getter
- Added dean mock user
- Updated role field documentation

#### `login_screen.dart`
- Added dean navigation logic
- Added dean demo account button

#### `signup_screen.dart`
- Added dean role option
- Added dean navigation logic

#### `main.dart`
- Added `/dean` route
- Imported DeanScreen

---

## 📊 Data Classes

### **DeanStatistics**
```dart
class DeanStatistics {
  int totalRequests = 0;
  int totalPending = 0;
  int totalAccepted = 0;
  int totalNotFound = 0;
  Map<String, ClassStatistics> classStats = {};
}
```

### **ClassStatistics**
```dart
class ClassStatistics {
  final int total;
  final int pending;
  final int accepted;
  final int notFound;
}
```

---

## 🧩 Dashboard Components

### **_StatCard Widget**
- Displays individual statistic
- Props: icon, label, value, color
- Gradient background
- Rounded corners

### **_ClassStatCard Widget**
- Displays class statistics
- Shows attendance progress bar
- Contains mini stats row
- Material card design

### **_MiniStat Widget**
- Small statistic display
- Icon + value + label
- Used in class cards
- Color-coded by status

---

## 📱 Screen Features

### **AppBar**
- Title: "Dean Dashboard"
- Profile icon button
- Material 3 elevation

### **Content Sections**
1. Welcome banner
2. Overall statistics (4 cards in 2×2 grid)
3. "Class-wise Breakdown" header
4. Class cards (one per class)

### **Interactions**
- Pull to refresh
- Tap profile icon → Navigate to profile
- Scroll to view all classes
- Visual feedback on loading

---

## 🎯 Use Cases

### **Use Case 1: Morning Overview**
**Scenario**: Dean checks morning attendance
1. Login to dean account
2. View overall pending requests
3. See which classes have most activity
4. Monitor attendance rates

### **Use Case 2: Class Performance**
**Scenario**: Compare class attendance
1. Scroll to class-wise breakdown
2. Compare attendance rates
3. Identify classes with issues
4. Take administrative action

### **Use Case 3: Real-time Monitoring**
**Scenario**: Track request resolution
1. Note pending count
2. Teachers respond to requests
3. Pull to refresh
4. See updated statistics

---

## 📊 Example Statistics Display

### **Sample Data**
```
Overall Statistics:
├─ Total Requests: 8
├─ Pending: 4
├─ Accepted: 2
└─ Not Found: 2

Class A:
├─ Total: 3
├─ Pending: 2
├─ Accepted: 1
├─ Not Found: 0
└─ Attendance Rate: 33%

Class B:
├─ Total: 3
├─ Pending: 2
├─ Accepted: 0
├─ Not Found: 1
└─ Attendance Rate: 0%

Class C:
├─ Total: 2
├─ Pending: 0
├─ Accepted: 1
├─ Not Found: 1
└─ Attendance Rate: 50%
```

---

## 🔐 Security & Access

### **Role Validation**
- Dean role checked in UserModel
- Navigation restricted by role
- No creation or handling permissions
- Read-only access to all data

### **Data Access**
- Views all classes (no filtering)
- Sees all request statuses
- Cannot modify requests
- Cannot change statuses

---

## 🚀 Benefits

### **For School Administration**
✅ Complete visibility across all classes
✅ Identify attendance patterns
✅ Monitor teacher responsiveness
✅ Track overall school attendance
✅ Data-driven decision making

### **For System**
✅ Centralized monitoring
✅ Real-time statistics
✅ No database queries (uses Cubit state)
✅ Efficient data aggregation
✅ Beautiful visualization

---

## 🎨 Visual Design

### **Color Psychology**
- **Blue**: Trust, authority (total counts)
- **Orange**: Attention, pending (awaiting action)
- **Green**: Success, positive (present)
- **Red**: Alert, negative (absent)

### **Layout Hierarchy**
1. Welcome (most important)
2. Overall stats (key metrics)
3. Class breakdown (detailed view)

### **Typography**
- Headers: Bold, large
- Values: Bold, colored
- Labels: Small, muted
- Google Fonts (Inter)

---

## 🧪 Testing Scenarios

### **Test 1: View Empty Dashboard**
1. Login as dean
2. If no requests, see zeros
3. Verify empty state handling

### **Test 2: View Populated Dashboard**
1. Login as dean
2. See mock data statistics
3. Verify calculations correct

### **Test 3: Pull to Refresh**
1. Pull down on dashboard
2. See loading indicator
3. Data refreshes

### **Test 4: Navigation**
1. Tap profile icon
2. Navigate to profile screen
3. Return to dashboard

---

## 📈 Future Enhancements

### **Potential Features**
- 📅 Date range filtering
- 📊 Charts and graphs
- 📥 Export reports (PDF/CSV)
- 🔔 Alert notifications
- 📈 Trend analysis
- 👥 Teacher performance metrics
- ⏰ Time-based statistics
- 🎯 Custom reports
- 📱 Weekly/monthly summaries
- 🔄 Historical data comparison

---

## 💡 Tips for Users

### **For Deans**
- Check dashboard regularly for overview
- Monitor pending count for delays
- Compare class attendance rates
- Use data for administrative decisions
- Pull to refresh for latest data

### **Best Practices**
- Review daily at start of school day
- Monitor trends over time
- Communicate with teachers about patterns
- Use statistics for staff meetings
- Track improvement over time

---

## 🎓 Summary

The Dean Dashboard provides:
- **Real-time oversight** of attendance system
- **Statistical analysis** across all classes
- **Beautiful visualization** of data
- **Easy-to-understand** metrics
- **Professional design** with Material 3

**Perfect for**: School administrators, principals, deans, and educational leadership who need comprehensive attendance monitoring and reporting.

---

**Made with ❤️ using Flutter + Cubit + Material 3**

**Dean Feature v1.0.0** ✨

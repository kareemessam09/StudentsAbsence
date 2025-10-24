# Backend: Manager Dashboard Statistics Endpoint

## Issue
Currently, the frontend manager dashboard fetches all classes individually and calculates statistics on the client side. This is inefficient and creates multiple API calls.

**Current Flow:**
1. Fetch all classes → `GET /api/classes`
2. For each class, fetch stats → `GET /api/classes/:id/stats` (N API calls)
3. Calculate totals on frontend

**Problems:**
- Multiple API calls (1 + N where N = number of classes)
- Heavy computation on client side
- Slow loading for large datasets
- Inconsistent data if changes happen during fetching

---

## Required Endpoint

### Route
```
GET /api/statistics/overview
```

### Authentication
- Required: Yes
- Role: Manager, Admin

### Response Format

#### Success (200 OK)
```json
{
  "status": "success",
  "data": {
    "overview": {
      "totalClasses": 15,
      "totalStudents": 450,
      "totalTeachers": 12,
      "totalCapacity": 600,
      "activeStudents": 445,
      "inactiveStudents": 5,
      "attendanceToday": {
        "present": 380,
        "absent": 70,
        "rate": 84.44
      },
      "classUtilization": {
        "filled": 450,
        "available": 150,
        "percentage": 75.0
      },
      "teacherStats": {
        "assigned": 10,
        "unassigned": 2
      },
      "classStats": {
        "withTeachers": 13,
        "withoutTeachers": 2,
        "full": 3,
        "nearCapacity": 5
      }
    },
    "recentActivity": {
      "newStudentsThisWeek": 15,
      "newClassesThisMonth": 2,
      "pendingNotifications": 8
    },
    "timestamp": "2025-10-24T15:45:00.000Z"
  }
}
```

---

## Implementation Guide

### Database Aggregation Example (MongoDB)

```javascript
const getManagerOverview = async (req, res, next) => {
  try {
    // Get all statistics in parallel
    const [
      classStats,
      studentStats,
      teacherStats,
      notificationStats
    ] = await Promise.all([
      // Class statistics
      Class.aggregate([
        {
          $group: {
            _id: null,
            totalClasses: { $sum: 1 },
            totalCapacity: { $sum: '$capacity' },
            totalStudents: { $sum: '$studentCount' },
            classesWithTeacher: {
              $sum: { $cond: [{ $ne: ['$teacher', null] }, 1, 0] }
            },
            classesWithoutTeacher: {
              $sum: { $cond: [{ $eq: ['$teacher', null] }, 1, 0] }
            }
          }
        }
      ]),

      // Student statistics
      Student.aggregate([
        {
          $group: {
            _id: null,
            totalStudents: { $sum: 1 },
            activeStudents: {
              $sum: { $cond: ['$isActive', 1, 0] }
            },
            inactiveStudents: {
              $sum: { $cond: [{ $not: '$isActive' }, 1, 0] }
            },
            newThisWeek: {
              $sum: {
                $cond: [
                  {
                    $gte: [
                      '$createdAt',
                      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
                    ]
                  },
                  1,
                  0
                ]
              }
            }
          }
        }
      ]),

      // Teacher statistics
      User.aggregate([
        {
          $match: { role: 'teacher' }
        },
        {
          $lookup: {
            from: 'classes',
            localField: '_id',
            foreignField: 'teacher',
            as: 'classes'
          }
        },
        {
          $group: {
            _id: null,
            totalTeachers: { $sum: 1 },
            teachersWithClasses: {
              $sum: { $cond: [{ $gt: [{ $size: '$classes' }, 0] }, 1, 0] }
            },
            teachersWithoutClasses: {
              $sum: { $cond: [{ $eq: [{ $size: '$classes' }, 0] }, 1, 0] }
            }
          }
        }
      ]),

      // Notification statistics
      Notification.aggregate([
        {
          $match: {
            status: 'pending',
            type: 'request'
          }
        },
        {
          $count: 'pendingNotifications'
        }
      ])
    ]);

    // Get today's attendance (if you have attendance collection)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const attendanceToday = await Attendance.aggregate([
      {
        $match: {
          date: { $gte: today }
        }
      },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    // Process results
    const classData = classStats[0] || {
      totalClasses: 0,
      totalCapacity: 0,
      totalStudents: 0,
      classesWithTeacher: 0,
      classesWithoutTeacher: 0
    };

    const studentData = studentStats[0] || {
      totalStudents: 0,
      activeStudents: 0,
      inactiveStudents: 0,
      newThisWeek: 0
    };

    const teacherData = teacherStats[0] || {
      totalTeachers: 0,
      teachersWithClasses: 0,
      teachersWithoutClasses: 0
    };

    const notificationData = notificationStats[0] || {
      pendingNotifications: 0
    };

    const presentCount = attendanceToday.find(a => a._id === 'present')?.count || 0;
    const absentCount = attendanceToday.find(a => a._id === 'absent')?.count || 0;
    const attendanceRate = classData.totalStudents > 0
      ? (presentCount / classData.totalStudents) * 100
      : 0;

    const utilizationPercentage = classData.totalCapacity > 0
      ? (classData.totalStudents / classData.totalCapacity) * 100
      : 0;

    // Build response
    res.status(200).json({
      status: 'success',
      data: {
        overview: {
          totalClasses: classData.totalClasses,
          totalStudents: classData.totalStudents,
          totalTeachers: teacherData.totalTeachers,
          totalCapacity: classData.totalCapacity,
          activeStudents: studentData.activeStudents,
          inactiveStudents: studentData.inactiveStudents,
          attendanceToday: {
            present: presentCount,
            absent: absentCount,
            rate: parseFloat(attendanceRate.toFixed(2))
          },
          classUtilization: {
            filled: classData.totalStudents,
            available: classData.totalCapacity - classData.totalStudents,
            percentage: parseFloat(utilizationPercentage.toFixed(2))
          },
          teacherStats: {
            assigned: teacherData.teachersWithClasses,
            unassigned: teacherData.teachersWithoutClasses
          },
          classStats: {
            withTeachers: classData.classesWithTeacher,
            withoutTeachers: classData.classesWithoutTeacher,
            full: 0, // TODO: Calculate classes at capacity
            nearCapacity: 0 // TODO: Calculate classes above 90% capacity
          }
        },
        recentActivity: {
          newStudentsThisWeek: studentData.newThisWeek,
          newClassesThisMonth: 0, // TODO: Calculate from Class.createdAt
          pendingNotifications: notificationData.pendingNotifications
        },
        timestamp: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
};
```

---

## Route Configuration

```javascript
// routes/statisticsRoutes.js
const express = require('express');
const router = express.Router();
const { protect, restrictTo } = require('../middleware/auth');
const { getManagerOverview } = require('../controllers/statisticsController');

router.get(
  '/overview',
  protect,
  restrictTo('manager', 'admin'),
  getManagerOverview
);

module.exports = router;
```

```javascript
// app.js
const statisticsRoutes = require('./routes/statisticsRoutes');

app.use('/api/statistics', statisticsRoutes);
```

---

## Benefits

### Performance
- ✅ **1 API call** instead of 1 + N calls
- ✅ **Database-level aggregation** (faster than client-side)
- ✅ **Cached results** possible (add Redis caching)
- ✅ **Consistent data** (single transaction)

### Scalability
- ✅ Works with 10 classes or 10,000 classes
- ✅ Minimal network traffic
- ✅ Reduced frontend memory usage

### Maintainability
- ✅ Single source of truth for statistics
- ✅ Easier to add new metrics
- ✅ Consistent calculations across platform

---

## Testing

```bash
# Login as manager
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "manager@school.com",
    "password": "password123"
  }'
# Copy the token

# Get statistics
curl -X GET http://localhost:3000/api/statistics/overview \
  -H "Authorization: Bearer <manager-token>" \
  -H "Content-Type: application/json"
```

Expected: Complete statistics object with all metrics

---

## Frontend Integration

### Before (Current - Inefficient)
```dart
// Multiple API calls
final classesResult = await _classService.getAllClasses();
final classes = classesResult['classes'];

for (var classModel in classes) {
  final statsResult = await _classService.getClassStats(classModel.id);
  // Calculate totals manually
}
```

### After (Optimized)
```dart
// Single API call
final statsResult = await _statisticsService.getManagerOverview();

final overview = statsResult['overview'];
print('Total Students: ${overview['totalStudents']}');
print('Present Today: ${overview['attendanceToday']['present']}');
print('Attendance Rate: ${overview['attendanceToday']['rate']}%');
```

---

## Caching Strategy (Optional)

For even better performance, cache the results:

```javascript
const getManagerOverview = async (req, res, next) => {
  try {
    // Check cache first
    const cached = await redis.get('manager:overview');
    if (cached) {
      return res.status(200).json(JSON.parse(cached));
    }

    // ... calculate statistics ...

    // Cache for 5 minutes
    await redis.setex('manager:overview', 300, JSON.stringify(response));

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
```

Invalidate cache when:
- New student added
- New class created
- Attendance marked
- Teacher assigned

---

## Additional Endpoints (Future)

```
GET /api/statistics/overview        - Overall statistics (this request)
GET /api/statistics/classes          - Per-class breakdown
GET /api/statistics/teachers         - Per-teacher statistics
GET /api/statistics/attendance       - Attendance trends (daily/weekly/monthly)
GET /api/statistics/trends           - Historical data for charts
```

---

## Priority: HIGH
This optimization will significantly improve manager dashboard performance.

**Estimated Impact:**
- Load time: ~3-5 seconds → <500ms
- API calls: 15-20 → 1
- Network data: ~500KB → ~5KB

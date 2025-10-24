# Backend Feature Request: Teacher Class Assignment Permissions

## Overview
We need to allow teachers to manage their own class assignments through the mobile app's profile screen. Currently, teachers receive a **403 Forbidden** error when attempting to update class assignments because they lack the necessary permissions.

## Current Issue
- **Error**: `Access denied. Insufficient permissions.`
- **Status Code**: 403 Forbidden
- **Endpoint**: `PUT /api/classes/:id`
- **User Role**: Teacher
- **Action**: Attempting to assign/unassign themselves to/from classes

## Request Details

### What We Need
Modify the backend API to allow teachers to update **only the `teacherId` field** of class records, but **only for themselves**. This means:

1. Teachers should be able to **assign themselves** to a class (set `teacherId` to their own ID)
2. Teachers should be able to **unassign themselves** from a class (set `teacherId` to empty string or null)
3. Teachers should **NOT** be able to assign other teachers to classes
4. Teachers should **NOT** be able to modify other class fields (name, capacity, studentIds, etc.)

### Recommended Implementation

#### Option 1: Add a New Endpoint (Preferred)
Create a dedicated endpoint for teacher self-assignment:

```
PUT /api/classes/:classId/assign-teacher
```

**Request Body:**
```json
{
  "assign": true  // or false to unassign
}
```

**Authorization:**
- Requires valid teacher JWT token
- Automatically uses authenticated teacher's ID

**Logic:**
- Extract teacher ID from JWT token
- If `assign: true` → set class.teacherId = authenticated teacher ID
- If `assign: false` → set class.teacherId = null (only if current teacherId matches authenticated teacher)

**Benefits:**
- Clear, specific purpose
- No risk of teachers modifying other fields
- Easy to secure and validate
- Self-documenting API

#### Option 2: Modify Existing Endpoint Permissions
Update the existing `PUT /api/classes/:id` endpoint:

**Current Behavior:**
- Only managers/admins can update class records

**New Behavior:**
- Managers/admins: Can update all fields (existing behavior)
- Teachers: Can ONLY update `teacherId` field, and ONLY to their own ID or null

**Validation Logic:**
```javascript
// Pseudo-code
if (user.role === 'teacher') {
  // Only allow teacherId field
  if (hasOtherFields(requestBody, ['teacherId'])) {
    return 403; // Forbidden - can't modify other fields
  }
  
  // Only allow setting to their own ID or unassigning
  if (requestBody.teacherId !== null && requestBody.teacherId !== user.id) {
    return 403; // Forbidden - can't assign to other teachers
  }
  
  // If unassigning, verify they are currently assigned
  if (requestBody.teacherId === null && class.teacherId !== user.id) {
    return 403; // Forbidden - can't unassign someone else
  }
  
  // Proceed with update
  updateClass({ teacherId: requestBody.teacherId });
}
```

### Frontend Implementation
Our frontend will send requests like:

**Assign Teacher to Class:**
```http
PUT /api/classes/68f92d51207e77586e93e779
Authorization: Bearer <teacher_jwt_token>
Content-Type: application/json

{
  "teacherId": "68fa5963f8fecea3cbea7ccf"
}
```

**Unassign Teacher from Class:**
```http
PUT /api/classes/68f92d51207e77586e93e779
Authorization: Bearer <teacher_jwt_token>
Content-Type: application/json

{
  "teacherId": ""
}
```

## Use Case
Teachers need to be able to manage which classes they are responsible for through the mobile app. This is a common workflow where:

1. Teacher opens their profile screen
2. Sees a list of all available classes
3. Selects/deselects the classes they want to manage
4. Clicks "Save Changes"
5. Backend updates the selected classes to assign the teacher

## Security Considerations
✅ Teachers can only assign themselves (not other teachers)  
✅ Teachers can only unassign themselves (not remove other teachers)  
✅ Teachers cannot modify class name, capacity, or student list  
✅ All changes require valid authentication token  
✅ Teacher ID is extracted from JWT token (not trusted from request body)

## Testing Recommendations
1. **Test Case 1**: Teacher assigns themselves to a class → Should succeed (200 OK)
2. **Test Case 2**: Teacher unassigns themselves from their own class → Should succeed (200 OK)
3. **Test Case 3**: Teacher tries to assign another teacher ID → Should fail (403 Forbidden)
4. **Test Case 4**: Teacher tries to unassign another teacher → Should fail (403 Forbidden)
5. **Test Case 5**: Teacher tries to update class name → Should fail (403 Forbidden) [if using Option 2]
6. **Test Case 6**: Manager updates any class field → Should succeed (200 OK) [existing behavior]

## Impact
- **Low Risk**: Only adds new permission for teachers, doesn't change existing manager permissions
- **High Value**: Enables self-service class management for teachers
- **User Experience**: Teachers can manage their workload independently

## Questions?
If you need any clarification or have suggestions for a better approach, please let us know!

---

**Priority**: Medium  
**Estimated Backend Effort**: 1-2 hours (for Option 1), 2-3 hours (for Option 2)  
**Frontend Status**: Ready to implement once backend changes are deployed

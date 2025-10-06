# Profile Management Feature

## Overview
Users can now manage their profile settings and change the class they manage (for teachers).

## New Features

### 1. Profile Screen (`/profile`)
A dedicated screen where users can:
- View their profile information
- Update their name and email
- **Teachers can change the class they manage**
- Logout with confirmation dialog

### 2. User Cubit Methods

#### `updateClassName(String newClassName)`
- **For Teachers Only**
- Updates the class a teacher manages
- Validates that the user is a teacher
- Shows loading state during update
- Returns to authenticated state with updated user

**Usage:**
```dart
context.read<UserCubit>().updateClassName('Class B');
```

#### `updateProfile({String? name, String? email})`
- Updates user's name and/or email
- Validates email uniqueness
- Shows loading state during update
- Handles errors gracefully

**Usage:**
```dart
context.read<UserCubit>().updateProfile(
  name: 'New Name',
  email: 'newemail@school.com',
);
```

### 3. Navigation

#### Access Profile Screen
Both Receptionist and Teacher screens now have a profile icon button in the AppBar:
- Tap the person icon (👤) in the top-right corner
- Navigates to `/profile` route

#### Route
```dart
'/profile' => ProfileScreen()
```

## UI Features

### Profile Screen Layout

1. **Profile Avatar**
   - Circle icon with role-based display
   - Receptionist: Person icon
   - Teacher: School icon
   - Role chip showing "Receptionist" or "Teacher"

2. **Form Fields**
   - Name (editable)
   - Email (editable with validation)
   - Managed Class (dropdown for teachers only)

3. **Class Selection (Teachers)**
   - Dropdown with available classes:
     - Class A
     - Class B
     - Class C
     - Class D
     - Class E
   - Info card explaining the feature
   - Only visible for teachers

4. **Action Buttons**
   - **Save Changes**: Updates profile with loading state
   - **Logout**: Shows confirmation dialog before logging out

### Animations
- FadeInDown for profile avatar
- FadeInLeft/Right for form fields
- FadeInUp for buttons
- Smooth transitions throughout

## User Flow

### Teacher Changes Class
1. Teacher logs in and navigates to Teacher Panel
2. Taps profile icon in AppBar
3. Selects new class from dropdown (e.g., "Class A" → "Class B")
4. Taps "Save Changes"
5. System shows loading indicator
6. Success message appears
7. Teacher now manages the new class
8. Attendance requests filtered for the new class

### Update Profile Information
1. User navigates to Profile screen
2. Updates name and/or email
3. Taps "Save Changes"
4. System validates changes
5. Success message appears
6. Profile updated throughout app

### Logout Flow
1. User taps "Logout" button
2. Confirmation dialog appears
3. User confirms logout
4. Navigates to login screen
5. All previous routes cleared

## Error Handling

### UserCubit Validations
- **updateClassName:**
  - ❌ No user logged in
  - ❌ User is not a teacher
  - ❌ Class name is empty

- **updateProfile:**
  - ❌ No user logged in
  - ❌ Email already exists (for different user)
  - ❌ Invalid email format (UI validation)

### Error Display
- Errors shown as red SnackBar with floating behavior
- Success shown as green SnackBar with check icon
- Loading states disable all form inputs

## Implementation Details

### State Management
- Uses BlocListener for navigation and notifications
- BlocBuilder for reactive UI updates
- Preserves user state after updates
- Rollback on error

### Data Persistence
- Changes stored in UserCubit's internal user list
- Simulates API calls with delays
- In production, would connect to backend API

### UI/UX Considerations
- Form validation on all fields
- Disabled inputs during loading
- Clear visual feedback for all actions
- Confirmation dialogs for destructive actions
- Responsive layout with proper spacing
- Material 3 design language

## Available Classes
Default classes available for teachers:
- Class A
- Class B
- Class C
- Class D
- Class E

_(Can be easily extended to add more classes)_

## Integration Points

### Receptionist Screen
- Profile button added to AppBar
- Navigator.pushNamed(context, '/profile')

### Teacher Screen
- Profile button added to AppBar
- Navigator.pushNamed(context, '/profile')
- Class changes affect visible attendance requests

### Main App Router
- New route: '/profile' => ProfileScreen()
- Same page transitions as other routes

## Testing

### Test Scenarios
1. **Change Class (Teacher)**
   - Login as emily.teacher@school.com
   - Current class: Class A
   - Change to Class B
   - Verify update success
   - Return to teacher panel
   - Check requests filtered for Class B

2. **Update Name/Email**
   - Login as any user
   - Change name to "New Name"
   - Change email to "newemail@school.com"
   - Verify update success
   - Check displayed name updated

3. **Logout Confirmation**
   - Tap logout button
   - Verify dialog appears
   - Test cancel (stays logged in)
   - Test confirm (returns to login)

4. **Error Cases**
   - Try duplicate email
   - Try empty class name
   - Verify error messages display

## Benefits

✅ Teachers can manage multiple classes flexibly
✅ No need to create multiple accounts
✅ Easy profile management in one place
✅ Clear feedback on all actions
✅ Secure logout with confirmation
✅ Responsive and animated UI
✅ Follows Material Design guidelines

# 🎯 Quick Reference - Responsive Design

## Import Statement
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive.dart';
```

## Common Patterns

### ✅ Text
```dart
// Before
Text('Hello', style: TextStyle(fontSize: 16))

// After
Text('Hello', style: TextStyle(fontSize: 16.sp))
```

### ✅ Icons
```dart
// Before
Icon(Icons.person, size: 24)

// After
Icon(Icons.person, size: 24.r)
```

### ✅ Padding
```dart
// Before
padding: EdgeInsets.all(16)

// After  
padding: Responsive.padding(all: 16)
```

### ✅ Spacing
```dart
// Before
SizedBox(height: 16)

// After
Responsive.verticalSpace(16)
```

### ✅ Border Radius
```dart
// Before
borderRadius: BorderRadius.circular(12)

// After
borderRadius: Responsive.borderRadius(12)
```

### ✅ Button Height
```dart
// Before
height: 56

// After
height: Responsive.buttonHeight(context)
```

### ✅ Center Content
```dart
// Wrap entire screen content
Responsive.centerContent(
  context: context,
  child: SingleChildScrollView(...),
)
```

## Device Detection
```dart
if (Responsive.isMobile(context)) {
  // Mobile layout
} else if (Responsive.isTablet(context)) {
  // Tablet layout  
} else {
  // Desktop layout
}
```

## Quick Conversions

| Old | New | Use For |
|-----|-----|---------|
| `fontSize: 16` | `fontSize: 16.sp` | All text |
| `size: 24` | `size: 24.r` | Icons, avatar |
| `width: 200` | `width: 200.w` | Widths |
| `height: 100` | `height: 100.h` | Heights |
| `EdgeInsets.all(16)` | `Responsive.padding(all: 16)` | Padding |
| `SizedBox(height: 20)` | `Responsive.verticalSpace(20)` | Spacing |
| `BorderRadius.circular(12)` | `Responsive.borderRadius(12)` | Corners |

## Checklist for New Screens

- [ ] Import responsive packages
- [ ] Convert all font sizes to `.sp`
- [ ] Convert all widths to `.w`
- [ ] Convert all heights to `.h`
- [ ] Convert all icons/radius to `.r`
- [ ] Use `Responsive.padding()` for padding
- [ ] Use `Responsive.verticalSpace()` / `horizontalSpace()`
- [ ] Use `Responsive.borderRadius()`
- [ ] Use `Responsive.buttonHeight(context)` for buttons
- [ ] Wrap with `Responsive.centerContent()` on large screens
- [ ] Test on different screen sizes

## ⚠️ Common Mistakes

### ❌ Don't Do This
```dart
padding: EdgeInsets.all(16.sp)  // Wrong - use .r for uniform sizing
fontSize: 16.w  // Wrong - use .sp for fonts
Icon(Icons.person, size: 24.sp)  // Wrong - use .r for icons
```

### ✅ Do This
```dart
padding: Responsive.padding(all: 16)  // Correct
fontSize: 16.sp  // Correct
Icon(Icons.person, size: 24.r)  // Correct
```

## Testing Sizes

### Flutter DevTools
```bash
# Run app
flutter run

# Then toggle device sizes in the toolbar
# Or use device emulators
```

### Test Checklist
- [ ] iPhone SE (small)
- [ ] iPhone 11 Pro (base)
- [ ] iPhone 11 Pro Max (large)
- [ ] iPad (tablet)
- [ ] Desktop (1920x1080)
- [ ] Portrait orientation
- [ ] Landscape orientation

## Need Help?

- See `RESPONSIVE_IMPLEMENTATION.md` for detailed guide
- See `RESPONSIVE_COMPLETE.md` for implementation summary
- See `lib/utils/responsive.dart` for helper methods

# 🎓 StudentNotifier

A modern Flutter application for managing school attendance with elegant Material 3 design, state management using Cubit, and smooth animations.

## ✨ Features

### 🏫 Core Functionality
- **Role-Based Access**: Separate interfaces for Receptionists, Teachers, and Dean
- **Attendance Management**: Send and track attendance requests
- **Real-time Status Updates**: Track request status (Pending, Accepted, Not Found)
- **Dean Dashboard**: Comprehensive statistics and analytics across all classes
- **Mock Data**: Pre-populated sample data for testing

### 🎨 Design & UX
- **Material 3 Design**: Modern, clean UI with elevation and depth
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Google Fonts**: Beautiful Inter font family for enhanced readability
- **Custom Animations**: 
  - Page transitions with fade and slide effects
  - Entry animations using animate_do package
  - Shimmer loading effects
  - Smooth status change animations

### 🏗️ Architecture
- **Cubit State Management**: Clean, predictable state management with flutter_bloc
- **Reusable Widgets**: RequestCard, EmptyState, and more
- **Clean Code Structure**: Organized folders for models, cubits, screens, and widgets

### 📦 Packages Used
- `flutter_bloc` ^8.1.6 - State management with Cubit
- `equatable` ^2.0.5 - Value equality for state classes
- `google_fonts` ^6.2.1 - Beautiful typography
- `animate_do` ^3.3.4 - Pre-built animations
- `intl` ^0.19.0 - Date/time formatting
- `shared_preferences` ^2.3.2 - Local data persistence
- `uuid` ^4.5.1 - Unique ID generation
- `shimmer` ^3.0.0 - Loading animations
- `font_awesome_flutter` ^10.7.0 - Icon library

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- An emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd students
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screens

### Login Screen (`/login`)
- Animated entrance with logo
- Role selection with demo accounts
- Smooth transitions to role-specific screens

### Receptionist Home Screen (`/receptionist`)
- Input form for student name and class selection
- Send attendance requests
- View all requests with status indicators
- Real-time updates via Cubit

### Teacher Home Screen (`/teacher`)
- View pending attendance requests
- Accept or mark students as "Not Found"
- Animated status updates
- Pending count badge in AppBar

### Dean Dashboard (`/dean`)
- **NEW!** Comprehensive statistics dashboard
- Overall attendance metrics (Total, Pending, Accepted, Not Found)
- Class-wise breakdown with attendance rates
- Real-time data visualization
- Pull-to-refresh functionality

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry + BlocProvider
├── cubits/
│   ├── request_cubit.dart             # Request state management
│   └── request_state.dart             # State classes
├── models/
│   └── request_model.dart             # Data model with mock data
├── screens/
│   ├── login_screen.dart              # Role selection
│   ├── receptionist_screen.dart       # Wrapper
│   ├── receptionist_home_screen.dart  # Receptionist UI
│   ├── teacher_screen.dart            # Wrapper
│   └── teacher_home_screen.dart       # Teacher UI
└── widgets/
    ├── request_card.dart              # Reusable request card
    └── empty_state.dart               # Animated empty state
```

## 🎯 Key Features Implementation

### State Management with Cubit
```dart
// Add a request
context.read<RequestCubit>().addRequest(
  studentName: 'John Doe',
  className: 'Class A',
);

// Update status
context.read<RequestCubit>().updateRequestStatus(
  id: requestId,
  status: 'Accepted',
);
```

### Animations
- **Page Transitions**: Custom fade + slide animations (300ms)
- **Entry Animations**: FadeInDown, FadeInLeft, FadeInRight
- **List Animations**: Staggered FadeInUp for each item
- **Empty State**: Fade + elastic scale animation

### Theming
- Automatic dark/light mode switching
- Material 3 color schemes
- Google Fonts (Inter) for consistent typography
- Custom color-coded status indicators

## 🎨 Color Coding
- 🟢 **Green**: Accepted status
- 🔴 **Red**: Not Found status
- 🟠 **Orange**: Pending status
- 🔵 **Blue**: Primary theme color

## 🔮 Future Enhancements
- [ ] Backend API integration
- [ ] Real-time push notifications
- [ ] User authentication
- [ ] Data persistence with local database
- [ ] Search and filter functionality
- [ ] Date/time range selection
- [ ] Export reports (PDF/CSV)
- [ ] Admin dashboard
- [ ] Analytics and reporting
- [ ] Multi-language support

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!

## 📄 License
This project is licensed under the MIT License.

## 👨‍💻 Author
Created with ❤️ using Flutter

---

**Note**: This app uses mock data for demonstration. In production, integrate with a backend API for real-time data management.

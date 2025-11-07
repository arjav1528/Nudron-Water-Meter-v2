# Water Meter 2 - Unified Mobile & Desktop App

This is a unified Flutter application that combines the mobile and desktop versions of the Nudron Water Metering application into a single codebase that supports all platforms.

## 🏗️ Project Structure

The project follows a clean architecture pattern with the following structure:

```
lib/
├── core/                    # Core utilities, constants, and themes
│   ├── config.dart         # App configuration
│   ├── theme/              # Theme management and UI components
│   └── utils/              # Utility functions and helpers
├── data/                   # Data layer
│   └── model/              # Data models and DTOs
├── domain/                 # Business logic layer
│   ├── bloc/               # State management (BLoC pattern)
│   ├── changeNotifiers/    # Change notifiers for state management
│   └── view_model/         # View models and business logic
├── presentation/           # Presentation layer
│   └── views/              # UI screens and widgets
├── platform/               # Platform-specific code
│   ├── mobile/             # Mobile-specific implementations
│   ├── desktop/            # Desktop-specific implementations
│   └── platform_utils.dart # Platform detection utilities
└── main.dart               # App entry point
```

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (>=3.3.1)
- Dart SDK
- Platform-specific development tools:
  - **Android**: Android Studio, Android SDK
  - **iOS**: Xcode (macOS only)
  - **Windows**: Visual Studio with C++ tools
  - **macOS**: Xcode
  - **Linux**: CMake, Ninja, GTK development libraries

### Installation

1. **Clone and navigate to the project:**
   ```bash
   cd /Users/arjavpatel/DevShit/watermeter2
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate app icons (optional):**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Apply package modifications:**
   
   This project requires a modification to the `date_picker_plus` package to display month names in uppercase in the date range picker. After running `flutter pub get`, you need to manually apply this change:
   
   **File to modify:**
   ```
   ~/.pub-cache/hosted/pub.dev/date_picker_plus-4.2.0/lib/src/range/range_days_picker.dart
   ```
   
   **Change required:**
   
   Find the `displayedDate` property (around line 406-417) and add `.toUpperCase()` at the end of the chain:
   
   **Before:**
   ```dart
   displayedDate: MaterialLocalizations.of(context)
       .formatMonthYear(_displayedMonth!)
       .replaceAll('٩', '9')
       .replaceAll('٨', '8')
       .replaceAll('٧', '7')
       .replaceAll('٦', '6')
       .replaceAll('٥', '5')
       .replaceAll('٤', '4')
       .replaceAll('٣', '3')
       .replaceAll('٢', '2')
       .replaceAll('١', '1')
       .replaceAll('٠', '0'),
   ```
   
   **After:**
   ```dart
   displayedDate: MaterialLocalizations.of(context)
       .formatMonthYear(_displayedMonth!)
       .replaceAll('٩', '9')
       .replaceAll('٨', '8')
       .replaceAll('٧', '7')
       .replaceAll('٦', '6')
       .replaceAll('٥', '5')
       .replaceAll('٤', '4')
       .replaceAll('٣', '3')
       .replaceAll('٢', '2')
       .replaceAll('١', '1')
       .replaceAll('٠', '0')
       .toUpperCase(),
   ```
   
   **Note:** This modification is required for the billing section's date range picker to display month names in uppercase (e.g., "NOVEMBER 2025" instead of "November 2025"). You'll need to reapply this change if you run `flutter pub get` again or if the package cache is cleared.

### Running the App

#### Mobile Platforms
```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

#### Desktop Platforms
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

#### Web (if needed)
```bash
flutter run -d web
```

### Building for Production

#### Mobile
```bash
# Android APK
flutter build apk --releas

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

#### Desktop
```bash
# Windows MSIX
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 🔧 Platform-Specific Features

### Mobile Features
- Portrait orientation lock
- Mobile-optimized UI (430x881.55 design size)
- Touch gestures and mobile-specific interactions
- Mobile-specific permissions and device features

### Desktop Features
- Window management and resizing
- Desktop-optimized UI (1920x1080 design size)
- Certificate handling for secure connections
- Desktop-specific keyboard shortcuts
- All orientation support

## 📱 Supported Platforms

- ✅ **Android** (API level 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🛠️ Development

### Code Organization
- **Core**: Shared utilities, themes, and configuration
- **Data**: Models and data structures
- **Domain**: Business logic, state management, and services
- **Presentation**: UI components and screens
- **Platform**: Platform-specific implementations

### State Management
The app uses BLoC (Business Logic Component) pattern for state management with Provider for dependency injection.

### Theming
The app supports both light and dark themes with platform-specific optimizations.

## 🔍 Troubleshooting

### Common Issues

1. **Import errors**: Make sure all imports use the correct package paths
2. **Platform-specific features**: Ensure you're running on the correct platform
3. **Dependencies**: Run `flutter pub get` after any pubspec.yaml changes
4. **Build issues**: Clean and rebuild with `flutter clean && flutter pub get`
5. **Date picker showing lowercase months**: If the date range picker shows "November" instead of "NOVEMBER", you need to apply the package modification documented in the Installation section. The modification must be reapplied after running `flutter pub get` or clearing the package cache.

### Debug Mode
```bash
flutter run --debug
```

### Release Mode
```bash
flutter run --release
```

## 📦 Dependencies

Key dependencies include:
- `flutter_bloc`: State management
- `provider`: Dependency injection
- `syncfusion_flutter_charts`: Chart components
- `window_manager`: Desktop window management
- `local_auth`: Biometric authentication
- `flutter_secure_storage`: Secure storage
- And many more (see pubspec.yaml)

## 🤝 Contributing

1. Follow the existing code structure
2. Use the established naming conventions
3. Add platform-specific code in the appropriate platform folders
4. Test on all target platforms before submitting changes

## 📄 License

This project is proprietary software owned by Nudron IoT.
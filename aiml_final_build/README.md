# Fitness Tracker System — Flutter

A cross-platform **Fitness Tracker** desktop application built with **Flutter** and **Dart**, developed as a **Software Engineering** project.

## Features

| Feature | Description |
|---|---|
| **User Profile** | Save name, age, height, and weight |
| **Workout Logging** | Log exercises (Running, Walking, Cycling, Strength Training) with duration |
| **Calorie Tracking** | Automatic calorie calculation using MET formula |
| **BMI Calculator** | Calculate BMI with WHO category classification |
| **Workout History** | View recent workout records in a data table |
| **Daily Summary** | See total calories burned today |
| **Data Persistence** | All data stored in CSV files |

## Architecture

```
lib/
├── main.dart                    # App entry point & theme configuration
├── models/
│   └── models.dart              # Data models (UserProfile, WorkoutRecord)
├── services/
│   ├── backend_service.dart     # Business logic & validation layer
│   └── database_service.dart    # CSV file persistence layer
├── screens/
│   └── home_screen.dart         # Main UI screen (Material Design 3)
└── utils/
    └── fitness_utils.dart       # Pure calculation functions (BMI, Calories)

test/
└── fitness_utils_test.dart      # Unit tests for calculations
```

### Design Pattern
The application follows a **layered architecture**:
- **View Layer** (`screens/`) — Flutter widgets for the UI
- **Service Layer** (`services/`) — Business logic and validation
- **Data Layer** (`services/database_service.dart`) — CSV file persistence
- **Utils** (`utils/`) — Pure, stateless calculation functions
- **Models** (`models/`) — Data transfer objects

## Prerequisites

1. **Flutter SDK** (3.0.0 or later)
2. **Dart SDK** (included with Flutter)
3. For Windows desktop: **Visual Studio 2022** with "Desktop development with C++" workload
4. For web: **Google Chrome** browser

## Flutter SDK Installation (Windows)

1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your system PATH
4. Open a new terminal and run:
   ```powershell
   flutter doctor
   ```
5. Fix any issues reported by `flutter doctor`

## Setup & Running

```powershell
# Navigate to the project directory
cd fitness_tracker_flutter

# Install dependencies
flutter pub get

# Run on Windows desktop
flutter run -d windows

# OR run on Chrome (web)
flutter run -d chrome
```

## Running Tests

```powershell
flutter test
```

## Calorie Formula

```
Calories = MET × Weight(kg) × Duration(min) × 0.0175
```

| Exercise | MET Value |
|---|---|
| Running | 8.0 |
| Walking | 3.5 |
| Cycling | 7.0 |
| Strength Training | 6.0 |

## BMI Categories (WHO)

| Category | BMI Range |
|---|---|
| Underweight | < 18.5 |
| Normal | 18.5 – 24.9 |
| Overweight | 25.0 – 29.9 |
| Obese | ≥ 30.0 |

## Technologies Used

- **Flutter** — Cross-platform UI framework
- **Dart** — Programming language
- **Material Design 3** — UI design system
- **CSV** — Data persistence format
- **path_provider** — Platform-specific file paths
- **intl** — Date formatting

## Author

Software Engineering Project — Fitness Tracker System

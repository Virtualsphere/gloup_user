# Folder Structure Guide

This project follows Clean Architecture principles with BLoC state management.

## 📁 Structure Overview

```
lib/
├── core/                          # Core functionality shared across features
│   ├── constants/                 # App-wide constants
│   │   ├── app_colors.dart       # Color palette (Green primary theme)
│   │   ├── app_sizes.dart        # Spacing, padding, margin constants
│   │   ├── app_strings.dart      # String constants
│   │   └── api_routes.dart       # API endpoint definitions
│   │
│   ├── theme/                     # Theme configuration
│   │   └── app_theme.dart        # Light & dark themes
│   │
│   ├── utils/                     # Utility functions
│   │   ├── validators.dart       # Input validation
│   │   ├── date_formatter.dart   # Date/time formatting
│   │   └── app_logger.dart       # Logging utility
│   │
│   ├── network/                   # Network layer
│   │   ├── network_info.dart     # Network connectivity
│   │   ├── api_response.dart     # Generic API response
│   │   ├── api_exception.dart    # Custom exceptions
│   │   └── README.md             # Place DioService & LoggerInterceptor here
│   │
│   ├── error/                     # Error handling
│   │   └── failures.dart         # Failure types
│   │
│   └── di/                        # Dependency injection
│       └── injection_container.dart  # GetIt setup
│
├── features/                      # Feature modules (Clean Architecture)
│   └── example/                   # Example feature (template)
│       ├── data/                  # Data layer
│       │   ├── models/           # Data models
│       │   ├── datasources/      # Remote & local data sources
│       │   └── repositories/     # Repository implementations
│       │
│       ├── domain/               # Domain layer (Business logic)
│       │   ├── entities/        # Business entities
│       │   ├── repositories/    # Repository interfaces
│       │   └── usecases/        # Use cases
│       │
│       └── presentation/         # Presentation layer
│           ├── bloc/            # BLoC (State management)
│           ├── pages/           # Screen pages
│           └── widgets/         # Feature-specific widgets
│
├── shared/                       # Shared across features
│   ├── widgets/                 # Reusable widgets
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   └── empty_widget.dart
│   │
│   ├── extensions/              # Dart extensions
│   │   ├── context_extensions.dart
│   │   └── string_extensions.dart
│   │
│   └── models/                  # Shared models
│
└── main.dart                    # App entry point
```

## 🏗️ Architecture Layers

### 1. **Presentation Layer**
- **BLoC**: State management (Events, States, BLoC)
- **Pages**: Screen UI
- **Widgets**: UI components

### 2. **Domain Layer** (Business Logic)
- **Entities**: Core business objects
- **Repositories**: Abstract interfaces
- **Use Cases**: Business use cases

### 3. **Data Layer**
- **Models**: Data transfer objects
- **Data Sources**: API/Local DB access
- **Repositories**: Repository implementations

## 🔄 Data Flow

```
UI (Page) → BLoC → Use Case → Repository → Data Source → API
                      ↓
                  Entity ← Model
```

## 📝 Creating a New Feature

1. **Create feature folder**: `lib/features/your_feature/`

2. **Domain layer** (Start here):
   ```
   domain/
   ├── entities/your_entity.dart
   ├── repositories/your_repository.dart
   └── usecases/your_usecase.dart
   ```

3. **Data layer**:
   ```
   data/
   ├── models/your_model.dart
   ├── datasources/your_remote_datasource.dart
   └── repositories/your_repository_impl.dart
   ```

4. **Presentation layer**:
   ```
   presentation/
   ├── bloc/
   │   ├── your_event.dart
   │   ├── your_state.dart
   │   └── your_bloc.dart
   ├── pages/your_page.dart
   └── widgets/your_widget.dart
   ```

5. **Register dependencies** in `injection_container.dart`

## 🎨 Theme & Colors

- **Primary**: Green family (`AppColors.primary`)
- All colors, sizes, and constants are centralized
- Use `AppSizes` for consistent spacing

## 🔌 Network Setup

After adding your `DioService` and `LoggerInterceptor`:
1. Place them in `lib/core/network/`
2. Register in `injection_container.dart`
3. Use in data sources

## 📦 Required Dependencies

Add these to `pubspec.yaml`:
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  dio: ^5.3.3
  intl: ^0.18.1

dev_dependencies:
  bloc_test: ^9.1.5
```

## 💡 Best Practices

1. ✅ Keep features independent
2. ✅ Use dependency injection
3. ✅ Follow naming conventions
4. ✅ Write testable code
5. ✅ Use const constructors
6. ✅ Handle errors properly
7. ✅ Use extensions for utilities
8. ✅ Keep widgets small and focused

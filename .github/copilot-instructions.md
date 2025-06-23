# GitHub Copilot Custom Instructions for BusMap-CanTho-v2

## Project Context
- This is a Flutter application for bus mapping in Can Tho city
- The app helps users navigate public transportation routes
- Key features include route visualization, bus stop information, and real-time updates

## Clean Architecture Structure
This project follows a strict clean architecture approach with three main layers:

### Layers
1. **Presentation Layer**
   - Contains UI components, screens, and widgets
   - Implements BLoC pattern for state management
   - No business logic, just UI rendering and user interaction handling

2. **Domain Layer**
   - Contains business logic and rules
   - Includes use cases (application-specific business rules)
   - Defines entity models and repository interfaces
   - Pure Dart code with no dependencies on Flutter or external packages

3. **Data Layer**
   - Implements repository interfaces from the domain layer
   - Contains data sources (remote, local)
   - Handles data mapping between API/database models and domain entities
   - Manages external service dependencies

### File Structure
```
lib/
├── core/
│   ├── common/
│   │   ├── constants/
│   │   ├── exceptions/
│   │   └── utils/
│   ├── config/
│   │   ├── routes/
│   │   └── themes/
│   ├── di/
│   │   └── injection_container.dart
│   └── network/
│       └── network_info.dart
├── features/
│   └── feature_name/ (e.g., bus_routes)
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── remote_datasource.dart
│       │   │   └── local_datasource.dart
│       │   ├── models/
│       │   │   └── model.dart
│       │   └── repositories/
│       │       └── repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── entity.dart
│       │   ├── repositories/
│       │   │   └── repository.dart
│       │   └── usecases/
│       │       └── usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── bloc.dart
│           │   ├── event.dart
│           │   └── state.dart
│           ├── pages/
│           │   └── page.dart
│           └── widgets/
│               └── widget.dart
└── main.dart
```

## Technical Preferences

### Architecture Principles
- Follow SOLID principles
- Dependencies should point inwards (domain layer has no dependencies on outer layers)
- Use dependency injection for managing dependencies between layers
- Use repository pattern to abstract data sources
- Implement use cases for each specific business operation

### Coding Style
- Follow Dart's official style guide
- Use clear, descriptive variable and function names
- Keep functions small and focused on a single responsibility
- Prefer immutable data structures when possible
- Use named parameters for functions with multiple parameters

### State Management
- Use BLoC pattern for state management
- Each feature has its own BLoC
- Follow unidirectional data flow
- BLoCs interact with use cases, never directly with repositories

### Map Integration
- Use Google Maps Flutter plugin for map implementation
- Map-related business logic belongs in domain layer use cases
- Map UI components stay in the presentation layer
- Create reusable components for map markers and information windows

### Navigation
- Use GoRouter for navigation
- Define routes in a centralized location (core/config/routes)
- Use named routes for deep linking support

### Localization
- Support Vietnamese and English languages
- Use Flutter's built-in localization system
- Store translations in assets/translations/ directory

### Testing
- Write unit tests for all domain layer components (entities, use cases)
- Test repositories with mock data sources
- Create widget tests for complex UI components
- Use mocks for external dependencies
- Aim for high test coverage on domain layer

## Specific Conventions
- Entity classes: PascalCase, no prefix (e.g., `BusRoute`, `BusStop`)
- Model classes: PascalCase with 'Model' suffix (e.g., `BusRouteModel`, `BusStopModel`)
- Repository interfaces: 'I' prefix + PascalCase + 'Repository' (e.g., `IBusRouteRepository`)
- Repository implementations: PascalCase + 'RepositoryImpl' (e.g., `BusRouteRepositoryImpl`)
- Use cases: PascalCase + action verb (e.g., `GetBusRoutes`, `UpdateBusLocation`)
- BLoC classes: Feature name + 'Bloc' (e.g., `BusRouteBloc`, `MapBloc`)
- Data sources: PascalCase + 'DataSource' (e.g., `BusRouteRemoteDataSource`)
- Use camelCase for variables and methods
- Use PascalCase for classes and enums

## Dependencies
- Use the latest stable Flutter version
- Minimize third-party dependencies
- Use dependency injection with get_it package
- Document why each dependency is needed

## Performance Considerations
- Optimize asset loading and caching
- Implement pagination for long lists
- Use lazy loading for map data
- Monitor memory usage, especially with map and location data

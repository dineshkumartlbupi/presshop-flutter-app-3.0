# Project Documentation

## Overview
This is a Flutter application built using **Clean Architecture** principles. It utilizes **Bloc** for state management and **GetIt** for dependency injection. The project is structured to separate concerns into **Core** (shared infrastructure) and **Features** (business logic).

## Architecture
The project follows a modular architecture:
- **Presentation Layer**: UI (Pages, Widgets) and State Management (Blocs).
- **Domain Layer**: Business Logic (Entities, Usecases, Repository Interfaces).
- **Data Layer**: Data retrieval (Repositories Implementation, Datasources, Models).

## Directory Structure (`lib/`)

The `lib` directory is the heart of the application and is organized as follows:

### 1. Root Files
- **`main.dart`**: The entry point of the application. It handles initialization of services (Firebase, DI, Environment, etc.) and runs the `MyApp` widget.
- **`app.dart`**: Contains the root `MyApp` widget. It sets up `MaterialApp`, themes, global providers (Riverpod `ProviderScope`), and the `ForceUpdateWidget`.
- **`firebase_options.dart`**: Auto-generated Firebase configuration.

### 2. Core (`lib/core/`)
Contains shared code used across multiple features.

- **`analytics/`**: Analytics helper classes and mixins (e.g., `AnalyticsHelper`, `AnalyticsMixin`).
- **`api/`**: Networking layer.
    - `api_client.dart`: Wrapper around Dio or HTTP client.
    - `network_class.dart`: Main network request handler.
    - `token_refresh_manager.dart`: Handles token refreshing logic.
- **`constants/`**: App-wide constants (Strings, Colors, Dimensions).
- **`di/`**: Dependency Injection setup using `get_it`.
    - `injection_container.dart`: Registers all dependencies (Blocs, Repositories, UseCases).
- **`error/`**: Error handling classes (`Failure`, `Exception`).
- **`models/`**: Shared data models.
- **`services/`**: Global services.
    - `app_initialization_service.dart`: Handles app startup logic.
    - `media_upload_service.dart`: Handles file uploads.
    - `deeplink_service.dart`: Manages deep linking.
- **`theme/`**: App theming (Colors, TextStyles).
- **`usecases/`**: Base `UseCase` class.
- **`utils/`**: Utility functions (Date formatting, Validators).
- **`widgets/`**: Reusable UI components (Buttons, TextFields, Loaders).

### 3. Features (`lib/features/`)
Each feature is a self-contained module following Clean Architecture.

**Common Feature Structure:**
- **`data/`**
    - `datasources/`: Remote and Local data sources (API calls, DB access).
    - `models/`: Data Transfer Objects (DTOs) that extend Entities (JSON parsing).
    - `repositories/`: Implementation of Domain Repositories.
- **`domain/`**
    - `entities/`: Pure business objects (no JSON logic).
    - `repositories/`: Abstract definitions of repositories.
    - `usecases/`: Business logic units (e.g., `LoginUser`, `GetPosts`).
- **`presentation/`**
    - `bloc/`: State management logic (Events, States, Blocs).
    - `pages/`: Screen widgets (UI).
    - `widgets/`: Feature-specific widgets.

**List of Features:**
- **`account_settings`**: User settings and preferences.
- **`alert`**: Alert and warning mechanisms.
- **`authentication`**: Login, Signup, Forgot Password.
- **`bank`**: Banking and payment information.
- **`camera`**: Camera functionality and media capture.
- **`chat`**: Real-time chat functionality.
- **`chatbot`**: AI or automated support chat.
- **`content`**: Content management.
- **`dashboard`**: Main app dashboard/home screen.
- **`earning`**: User earnings tracking.
- **`feed`**: Social feed or content stream.
- **`leaderboard`**: User rankings.
- **`map`**: Map view and location-based features.
- **`menu`**: Navigation menu.
- **`notification`**: Push and local notifications.
- **`onboarding`**: User onboarding flow.
- **`profile`**: User profile management.
- **`publication`**: Publishing content.
- **`publish`**: Logic for publishing.
- **`rating`**: Rating and review system.
- **`referral`**: User referral system.
- **`splash`**: Splash screen and initial app logic.
- **`task`**: Task management.

## Key Files & Responsibilities

| File | Responsibility |
|------|----------------|
| `lib/main.dart` | **Entry Point**. Initializes `WidgetsFlutterBinding`, Firebase, DI, and runs `MyApp`. |
| `lib/app.dart` | **Root Widget**. Configures `MaterialApp`, `ThemeData`, and global wrappers like `ProviderScope`. |
| `lib/core/di/injection_container.dart` | **Dependency Injection**. Registers all singletons and factories for the app. |
| `lib/core/api/network_class.dart` | **Networking**. Handles HTTP requests, interceptors, and error parsing. |
| `lib/features/splash/presentation/pages/SplashScreen.dart` | **Initial Logic**. Checks auth state, force updates, and navigates to Login or Dashboard. |

## State Management
The project primarily uses **flutter_bloc** for managing state.
- **Events**: User actions (e.g., `LoginButtonPressed`).
- **States**: UI states (e.g., `LoginLoading`, `LoginSuccess`, `LoginFailure`).
- **Blocs**: Business logic that maps Events to States.

*Note: `flutter_riverpod` is also present (`ProviderScope` in `app.dart`), possibly for specific global states or legacy code.*

## Navigation
Navigation is handled via standard Flutter `Navigator` (Navigator 1.0/2.0 mix).
- **Global Key**: `navigatorKey` in `main.dart` allows navigation from non-context locations (though discouraged).
- **Manual Routes**: `Navigator.push(MaterialPageRoute(...))` is used in `SplashScreen.dart`.

## External Dependencies (Key)
- **`dio`**: HTTP client.
- **`get_it`**: Service Locator.
- **`flutter_bloc`**: State Management.
- **`firebase_*`**: Backend services (Auth, Analytics, Crashlytics).
- **`google_maps_flutter`**: Maps integration.
- **`shared_preferences`**: Local storage.

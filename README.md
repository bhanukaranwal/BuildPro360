# BuildPro360 Mobile Application

![BuildPro360 Logo](assets/images/logo.png)

**Current Version:** 1.2.3  
**Last Updated:** August 16, 2025  
**Author:** BuildPro360 Development Team

## Overview

BuildPro360 is a comprehensive construction management mobile application designed to streamline asset tracking, project management, maintenance, and compliance processes. The application provides real-time monitoring of assets, IoT device integration, and robust reporting capabilities to help construction companies improve operational efficiency and reduce costs.

## Features

### Core Functionality

- **Dashboard**: Real-time overview of projects, assets, inspections, and alerts
- **Asset Management**: Track equipment, tools, vehicles, and other assets
- **Project Management**: Create and manage projects, tasks, and resources
- **Maintenance**: Schedule and track work orders and preventive maintenance
- **Compliance**: Manage inspections, certifications, and regulatory requirements
- **IoT Integration**: Connect with and monitor IoT devices deployed on construction sites
- **Reporting**: Generate detailed reports on various aspects of construction operations

### Key Features

- **Asset Tracking**
  - Real-time location tracking
  - Utilization monitoring
  - Maintenance history
  - Document storage (manuals, warranties, certificates)

- **Project Management**
  - Task assignment and tracking
  - Resource allocation
  - Timeline visualization
  - Budget management
  - Progress tracking

- **Work Order Management**
  - Create and assign work orders
  - Prioritize maintenance tasks
  - Track completion status
  - Document issues with photos
  - Maintenance history reporting

- **Compliance and Inspections**
  - Schedule inspections
  - Customizable inspection checklists
  - Photo evidence collection
  - Non-compliance flagging
  - Corrective action tracking

- **IoT Device Integration**
  - Real-time sensor data monitoring
  - Equipment performance tracking
  - Environmental condition monitoring
  - Automated alerts for anomalies
  - Remote device control

- **Analytics and Reporting**
  - Customizable report templates
  - Data visualization
  - Export to multiple formats
  - Scheduled report generation
  - Insights and trend analysis

## System Architecture

BuildPro360 follows a clean architecture approach with a clear separation of concerns:

- **Presentation Layer**: Flutter UI components and BLoC pattern for state management
- **Domain Layer**: Business logic and domain models
- **Data Layer**: Repository pattern for data access with remote and local data sources

### State Management

The application uses the BLoC (Business Logic Component) pattern for state management, providing a predictable and testable architecture with clear separation between UI and business logic.

### Data Flow

1. User interacts with the UI
2. UI dispatches events to the BLoC
3. BLoC processes events, communicates with repositories
4. Repositories fetch data from local storage or API
5. BLoC emits new states based on the data
6. UI rebuilds based on the new state

## Technology Stack

- **Frontend**: Flutter SDK
- **State Management**: Flutter BLoC
- **API Communication**: HTTP package with RESTful API
- **Local Storage**: SharedPreferences and Secure Storage
- **Authentication**: JWT with secure token storage
- **Real-time Communication**: WebSockets for IoT device data
- **Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Maps and Location**: Google Maps API and Geolocator
- **Image Handling**: Image Picker and Cached Network Image
- **Charts and Graphs**: FL Chart

## Getting Started

### Prerequisites

- Flutter SDK (version 3.10.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code with Flutter plugins
- Firebase project (for FCM and Analytics)
- API access credentials for BuildPro360 backend

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/buildpro360/mobile-app.git
cd BuildPro360/mobile
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure environment variables**

Create a `.env` file in the project root with the following variables:

```
API_BASE_URL=https://api.buildpro360.com/v1
API_WS_URL=wss://api.buildpro360.com/ws
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

4. **Configure Firebase**

- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android and iOS apps to your Firebase project
- Download and add the `google-services.json` file to `android/app/`
- Download and add the `GoogleService-Info.plist` file to `ios/Runner/`

5. **Run the application**

```bash
flutter run
```

### Building for Production

#### Android

```bash
flutter build apk --release
# OR
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

## Project Structure

```
lib/
│
├── config/                 # Application configuration
│   ├── constants/          # Constants and static data
│   ├── routes/             # Navigation routes
│   └── theme/              # Theme configuration
│
├── core/                   # Core functionality
│   ├── services/           # Common services
│   ├── utils/              # Utility functions
│   └── widgets/            # Shared widgets
│
├── features/               # Application features
│   ├── assets/             # Asset management feature
│   │   ├── data/           # Data sources and repositories
│   │   ├── domain/         # Domain models and business logic
│   │   └── presentation/   # UI components and BLoCs
│   │
│   ├── auth/               # Authentication feature
│   ├── dashboard/          # Dashboard feature
│   ├── compliance/         # Compliance feature
│   ├── iot/                # IoT device feature
│   ├── maintenance/        # Maintenance feature
│   ├── projects/           # Project management feature
│   ├── reports/            # Reporting feature
│   └── settings/           # User settings feature
│
└── main.dart               # Application entry point
```

## Key Components

### Services

- **ApiService**: Handles API communication with error handling and retry logic
- **LocalStorageService**: Manages local data persistence
- **AuthenticationService**: Handles user authentication and token management
- **NotificationService**: Manages push notifications
- **AnalyticsService**: Tracks user behavior and application usage
- **ConnectivityService**: Monitors network connectivity

### BLoCs

Each feature has its own BLoC to manage state:

- **AuthBloc**: Authentication state management
- **DashboardBloc**: Dashboard data and state
- **AssetsBloc**: Asset list and details
- **ProjectsBloc**: Project list and details
- **MaintenanceBloc**: Work order management
- **ComplianceBloc**: Inspection management
- **IoTBloc**: IoT device management
- **ReportsBloc**: Report generation and management

## Security Features

- **Secure Storage**: Sensitive data (tokens, credentials) stored in secure storage
- **JWT Authentication**: Secure token-based authentication
- **SSL Pinning**: Certificate pinning for API communication
- **Biometric Authentication**: Optional fingerprint/face ID login
- **Session Management**: Automatic logout after inactivity
- **Input Validation**: Form validation to prevent injection attacks

## Offline Capabilities

BuildPro360 provides offline functionality through:

- **Local Data Caching**: Essential data cached for offline access
- **Synchronization Queue**: Changes made offline are queued for sync when online
- **Conflict Resolution**: Smart handling of conflicts during data synchronization
- **Background Sync**: Automatic synchronization when connectivity is restored

## Performance Optimization

- **Lazy Loading**: Data loaded on-demand to reduce initial load time
- **Image Optimization**: Efficient image caching and loading
- **Pagination**: List data loaded in pages to improve performance
- **Memory Management**: Efficient resource handling to minimize memory usage
- **Background Processing**: Heavy tasks performed in the background

## Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Coverage report
flutter test --coverage
```

## Troubleshooting

### Common Issues

1. **API Connection Issues**
   - Check internet connectivity
   - Verify API base URL in configuration
   - Ensure authentication token is valid

2. **Firebase Integration Issues**
   - Verify Firebase configuration files are correctly placed
   - Check Firebase project settings for correct app IDs

3. **Build Errors**
   - Run `flutter clean` followed by `flutter pub get`
   - Ensure Flutter SDK is up to date

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

We follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For support or inquiries:
- Email: support@buildpro360.com
- Website: https://buildpro360.com

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [BLoC Library](https://bloclibrary.dev/)
- All open-source packages used in this project
```

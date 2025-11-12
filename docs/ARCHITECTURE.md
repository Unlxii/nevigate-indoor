# Project Architecture

## Overview

Indoor Navigation App ใช้ Clean Architecture และ BLoC pattern สำหรับ state management

## Layer Structure

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, Widgets, BLoC, Screens)       │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│         Domain Layer                │
│  (Entities, Use Cases, Interfaces)  │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│          Data Layer                 │
│  (Repositories, Services, Models)   │
└─────────────────────────────────────┘
```

## Detailed Architecture

### 1. Presentation Layer

#### BLoC Pattern

```
User Action → Event → BLoC → State → UI Update
```

**BLoCs:**

- `AuthBloc`: การจัดการ Authentication
- `PositioningBloc`: การจัดการตำแหน่ง UWB
- `NavigationBloc`: การจัดการนำทาง

#### Screens:

- `SplashScreen`: หน้าเริ่มต้น
- `LoginScreen`: หน้า Login/Register
- `MainScreen`: หน้าหลักที่มี BottomNav
- `MapViewScreen`: หน้าแสดงแผนที่
- `AdminDashboardScreen`: หน้าจัดการผู้ใช้ (Admin)

### 2. Domain Layer

#### Entities:

```dart
Position        // ตำแหน่งพิกัด
Room            // ข้อมูลห้อง
UserModel       // ข้อมูลผู้ใช้
NavigationPath  // เส้นทางนำทาง
```

### 3. Data Layer

#### Services:

- `BluetoothService`: จัดการ Bluetooth connection
- `UWBService`: ประมวลผลข้อมูล UWB

#### Repositories:

- `AuthRepository`: จัดการ Authentication และ User data
- `UWBRepository`: จัดการข้อมูลตำแหน่ง
- `NavigationRepository`: จัดการข้อมูลห้องและการนำทาง

## Data Flow

### 1. Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│          │────▶│          │────▶│          │
│ UI Input │     │ AuthBloc │     │ Firebase │
│          │◀────│          │◀────│ Auth     │
└──────────┘     └──────────┘     └──────────┘
```

### 2. Positioning Flow

```
┌─────────┐    ┌──────────┐    ┌────────┐    ┌──────────────┐
│         │───▶│Bluetooth │───▶│  UWB   │───▶│ Positioning  │
│ESP WD   │    │ Service  │    │Service │    │    BLoC      │
│  1000   │◀───│          │◀───│        │◀───│              │
└─────────┘    └──────────┘    └────────┘    └──────────────┘
                                                      │
                                                      ▼
                                              ┌──────────────┐
                                              │   Map View   │
                                              └──────────────┘
```

### 3. Navigation Flow

```
User Search → NavigationBloc → Firestore → Pathfinding → MapView
```

## State Management

### BLoC Pattern Example

```dart
// Event
class LoadRoomsEvent extends NavigationEvent {}

// State
class RoomsLoadedState extends NavigationState {
  final List<Room> rooms;
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  Future<void> _onLoadRooms(event, emit) async {
    final rooms = await repository.getRooms();
    emit(RoomsLoadedState(rooms: rooms));
  }
}
```

## Design Patterns Used

1. **Repository Pattern**: แยก data source logic
2. **BLoC Pattern**: state management
3. **Singleton Pattern**: services
4. **Factory Pattern**: entity creation
5. **Observer Pattern**: stream subscriptions

## Dependencies

### Core

- `flutter_bloc`: State management
- `provider`: Dependency injection
- `equatable`: Value equality

### Firebase

- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database

### Bluetooth & UWB

- `flutter_blue_plus`: Bluetooth communication
- `permission_handler`: Runtime permissions

### UI

- `google_fonts`: Typography
- `flutter_svg`: Vector graphics

### Utilities

- `rxdart`: Reactive programming
- `shared_preferences`: Local storage
- `intl`: Internationalization

## Testing Strategy

### Unit Tests

```dart
// BLoC tests
test('should emit RoomsLoadedState when rooms are loaded', () {
  // Arrange
  // Act
  // Assert
});
```

### Integration Tests

```dart
// Screen navigation tests
testWidgets('should navigate to MapView after login', (tester) async {
  // Arrange
  // Act
  // Assert
});
```

### Widget Tests

```dart
// UI component tests
testWidgets('should display room name', (tester) async {
  // Arrange
  // Act
  // Assert
});
```

## Performance Optimization

### 1. การจัดการ Memory

- ใช้ `const` constructors
- Dispose streams และ controllers
- ใช้ `ListView.builder` สำหรับ lists

### 2. การจัดการ Network

- Cache Firestore data
- Batch operations
- Offline persistence

### 3. การจัดการ UI

- Use `RepaintBoundary`
- Optimize `CustomPainter`
- Lazy loading

## Security

### 1. Authentication

- Firebase Authentication
- Role-based access control
- Email verification

### 2. Data

- Firestore security rules
- Data validation
- Encrypted storage

### 3. Bluetooth

- Secure pairing
- Data encryption
- Device whitelist

## Future Improvements

1. **Offline Mode**: Cache maps and work offline
2. **AR Navigation**: Augmented reality navigation
3. **Multi-floor**: Elevator and stair navigation
4. **Analytics**: Usage tracking and heatmaps
5. **Voice Navigation**: Turn-by-turn voice guidance
6. **Accessibility**: Screen reader support
7. **Dark Mode**: Complete dark theme
8. **Localization**: Multi-language support

## Folder Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── uwb_repository.dart
│   │   └── navigation_repository.dart
│   └── services/
│       ├── bluetooth_service.dart
│       └── uwb_service.dart
├── domain/
│   └── entities/
│       ├── position.dart
│       ├── room.dart
│       ├── user_model.dart
│       └── navigation_path.dart
├── presentation/
│   ├── bloc/
│   │   ├── auth/
│   │   ├── positioning/
│   │   └── navigation/
│   ├── screens/
│   │   ├── auth/
│   │   ├── main/
│   │   ├── map/
│   │   └── admin/
│   └── widgets/
│       ├── floor_map_painter.dart
│       └── room_search_delegate.dart
└── main.dart
```

## Contributing Guidelines

1. Follow Clean Architecture principles
2. Write tests for new features
3. Update documentation
4. Use meaningful commit messages
5. Create feature branches
6. Review code before merging

## Resources

- [Flutter Best Practices](https://flutter.dev/docs/development/ui/best-practices)
- [BLoC Library](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

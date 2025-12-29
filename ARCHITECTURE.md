# Darna Restaurant App - Architecture

## 🏗️ Overview

Darna follows **Clean Architecture** principles with clear separation of concerns across three main layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Widgets, State Management)        │
└────────────┬────────────────────────────┘
             │ depends on
┌────────────▼────────────────────────────┐
│          Domain Layer                   │
│   (Business Logic, Entities, Use Cases) │
└────────────┬────────────────────────────┘
             │ depends on
┌────────────▼────────────────────────────┐
│           Data Layer                    │
│  (Repositories, Data Sources, Models)   │
└─────────────────────────────────────────┘
```

## 📁 Layer Breakdown

### 1. Presentation Layer (`lib/features/*/presentation`)

**Responsibilities:**
- UI components and screens
- State management (Riverpod providers)
- User input handling
- Displaying data from domain layer

**Key Components:**
- `screens/` - Full-screen widgets
- `widgets/` - Reusable UI components  
- `providers/` - Riverpod state providers

**Example:**
```dart
features/product/presentation/
├── screens/
│   └── product_detail_screen.dart
├── widgets/
│   └── product_card.dart
└── providers/
    └── product_provider.dart
```

### 2. Domain Layer (`lib/features/*/domain`)

**Responsibilities:**
- Business logic
- Entity definitions
- Use case implementations
- Repository interfaces

**Key Components:**
- `entities/` - Pure business objects
- `repositories/` - Abstract repository interfaces
- `usecases/` *(optional)* - Application-specific business rules

**Example:**
```dart
features/product/domain/
├── entities/
│   └── product.dart  // Pure Dart class
└── repositories/
    └── product_repository.dart  // Abstract interface
```

### 3. Data Layer (`lib/features/*/data`)

**Responsibilities:**
- Data fetching and persistence
- API/Firebase integration
- Caching logic
- Repository implementations

**Key Components:**
- `repositories/` - Concrete repository implementations
- `models/` - Data transfer objects (DTOs)
- `datasources/` - Remote/local data sources
- `services/` - External service integrations

**Example:**
```dart
features/product/data/
├── repositories/
│   └── firestore_product_repository.dart
├── models/
│   └── product_model.dart
└── services/
    └── firestore_service.dart
```

## 🔄 Data Flow

```
User Interaction
     ↓
 Widget (Presentation)
     ↓
Provider (State Management)
     ↓
Repository (Data Layer)
     ↓
Firebase/API
     ↓
Model → Entity
     ↓
Provider Updates
     ↓
Widget Rebuilds
```

## 🎯 Feature Modules

Each feature is self-contained:

```
features/
├── auth/
│   ├── data/          # Firebase auth implementation
│   ├── domain/        # User entity, auth repository interface
│   └── presentation/  # Login/signup screens
├── product/
├── cart/
├── order/
├── delivery/
└── admin/
```

## 🧩 Core Module

Shared utilities and services:

```
core/
├── constants/     # App-wide constants
├── theme/         # Theme configuration
├── widgets/       # Reusable widgets
├── services/      # Shared services (storage, location)
├── router/        # App navigation
└── utils/         # Helper functions
```

## 📦 State Management (Riverpod)

**Provider Types:**
- `Provider` - Immutable, computed values
- `StateProvider` - Simple mutable state
- `FutureProvider` - Async data fetching
- `StreamProvider` - Real-time data streams
- `StateNotifierProvider` - Complex state logic

**Example:**
```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final result = await repository.getProducts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});
```

## 🗺️ Navigation (GoRouter)

Declarative routing with path-based navigation:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),
  ],
);
```

## 🔥 Firebase Integration

### Firestore
- Real-time data sync
- Offline persistence
- Security rules enforcement

### Authentication
- Email/password auth
- Role-based access (customer, driver, admin)
- Anonymous guest mode

### Storage
- Image uploads with compression
- WebP conversion for optimization
- Automatic caching

## 🎨 UI/UX Architecture

### Theme System
- Light/dark mode support
- Consistent color palette
- Material Design 3
- Custom Moroccan-inspired styling

### Responsive Design
- Adaptive layouts
- Multi-device support (phone, tablet)
- Orientation handling

### Animations
- Flutter Animate for smooth transitions
- Shimmer loading effects
- Hero animations for shared elements

## 🧪 Testing Strategy

```
test/
├── unit/          # Business logic tests
├── widget/        # UI component tests
└── integration/   # End-to-end tests
```

## 🔐 Security

- **Firestore Rules** - Server-side access control
- **Input Validation** - Client-side data validation
- **Secure Storage** - Encrypted local storage (coming soon)
- **API Key Protection** - Environment variables

## 📈 Scalability Considerations

- Lazy loading for products
- Image caching and optimization
- Pagination for large datasets
- Efficient state management
- Modular feature architecture

## 🛠️ Build Variants

```
environments/
├── dev/      # Development configuration
├── staging/  # Staging configuration
└── prod/     # Production configuration
```

## 📚 References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)

---

This architecture ensures:
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability
- ✅ Separation of concerns
- ✅ Easy feature additions

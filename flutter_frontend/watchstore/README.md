# watchstore

watch store - ecommerce application using flutter and other modern tools

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Proposed Project Structure
lib/
├── main.dart                       👈 App entry point
├── constants/                     📁 App-wide constants (colors, assets, etc.)
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_assets.dart
├── models/                        📁 Data models (Product, User, Order, CartItem)
│   └── product_model.dart
│   └── user_model.dart
│   └── order_model.dart
├── services/                      📁 Firebase services & DB logic
│   └── auth_service.dart
│   └── firestore_service.dart
│   └── storage_service.dart
├── providers/                     📁 State management (Provider or Riverpod)
│   └── auth_provider.dart
│   └── cart_provider.dart
│   └── product_provider.dart
│   └── order_provider.dart
├── screens/                       📁 UI Screens
│   ├── auth/
│   │   └── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   │   └── product_grid.dart
│   ├── product/
│   │   └── product_detail_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── order/
│   │   └── order_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── widgets/                       📁 Reusable widgets
│   └── custom_button.dart
│   └── product_card.dart
│   └── custom_app_bar.dart
│   └── cart_item_tile.dart
├── routes/                        📁 App navigation (named routes)
│   └── app_routes.dart
│   └── route_generator.dart
├── utils/                         📁 Helper functions, validators, etc.
│   └── validators.dart
│   └── formatters.dart
└── config/                        📁 Firebase options or environment configs
└── firebase_options.dart      👈 Auto-generated with FlutterFire CLI

## Proposed App Navigation Flow
                ┌────────────────────────────┐
                │        main.dart           │
                │ - runApp(WristifiedApp)    │
                │ - initialRoute = splash    │
                └────────────┬───────────────┘
                             │
                             ▼
                 ┌──────────────────────┐
                 │  /splash             │
                 │ SplashScreen         │
                 └──────┬───────────────┘
                        │ after 2-3 sec (or logic)
                        ▼
                ┌──────────────────────┐
                │  /login              │
                │ LoginScreen          │
                └──────┬───────────────┘
                       │ if user taps "Sign Up"
                       ▼
                ┌──────────────────────┐
                │  /signup             │
                │ SignupScreen         │
                └──────┬───────────────┘
                       │ if auth success
                       ▼
                ┌──────────────────────┐
                │  /home               │
                │ HomeScreen           │
                └──────┬───────────────┘
                       │ select product
                       ▼
                ┌──────────────────────────────┐
                │  /product_detail             │
                │ ProductDetailScreen          │
                └──────┬───────────────┬───────┘
                       │               │
            ┌──────────▼───────┐      ▼
            │  /cart          │   /profile
            │ CartScreen      │   ProfileScreen
            └─────────────────┘      ▼
                               ┌───────────────┐
                               │  /orders      │
                               │ OrderScreen   │
                               └───────────────┘



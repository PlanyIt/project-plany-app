flutter pub run build_runner build --delete-conflicting-outputs

flutter run --target lib/main_staging.dart

lib/
├── data/
│ ├── repositories/ ← Implémentations concrètes
│ ├── services/ ← ApiClient, SharedPrefs, etc.
├── domain/
│ ├── models/ ← Plan, User, etc.
│ ├── repositories/ ← Abstractions (interfaces)
├── application/
│ ├── session_manager.dart ← Coordination login/logout + cache
├── ui/
│ ├── screens/
│ ├── widgets/
├── utils/

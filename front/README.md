flutter pub run build_runner build --delete-conflicting-outputs

flutter run

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

# Plany Admin

Administration interface for the Plany application.

## Overview

This admin panel allows management of plans, steps, categories, and users. It connects to the Plany backend API to fetch and manipulate real data.

## Features

- Authentication with Firebase
- Real-time data from backend API
- Management of:
  - Plans
  - Steps
  - Categories
  - Users
- Dashboard with analytics

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase project configuration
- Backend API access

### Environment Setup

1. Create a `.env` file in the project root with:

```
BASE_URL=https://your-backend-api-url.com
```

2. Run `flutter pub get` to install dependencies

3. Start the app with `flutter run`

## Backend Integration

This admin panel connects to the Plany backend API to fetch and manipulate real data. Authentication is handled via Firebase tokens which are sent with each API request.

flutter pub run build_runner build --delete-conflicting-outputs


lib/
├── data/
│   ├── repositories/
│   │   ├── plan_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   └── comment_repository.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   └── location_service.dart
│   └── models/
│       ├── api_plan.dart
│       ├── api_user.dart
│       └── api_response.dart
├── domain/
│   └── models/
│       ├── plan.dart
│       ├── user.dart
│       ├── category.dart
│       ├── step.dart
│       └── comment.dart
├── ui/
│   ├── core/
│   │   ├── themes/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── localization/
│   │   │   └── app_localization.dart
│   │   └── widgets/
│   │       ├── base_button.dart
│   │       ├── loading_indicator.dart
│   │       └── error_widget.dart
│   ├── auth/
│   │   ├── view_model/
│   │   │   └── auth_view_model.dart
│   │   └── widgets/
│   │       ├── auth_screen.dart
│   │       ├── login_form.dart
│   │       └── register_form.dart
│   ├── home/
│   │   ├── view_model/
│   │   │   └── home_view_model.dart
│   │   └── widgets/
│   │       ├── home_screen.dart
│   │       ├── plan_card.dart
│   │       └── search_bar.dart
│   ├── plan_details/
│   │   ├── view_model/
│   │   │   └── plan_details_view_model.dart
│   │   └── widgets/
│   │       ├── plan_details_screen.dart
│   │       ├── plan_content.dart
│   │       ├── plan_info_section.dart
│   │       ├── steps_carousel.dart
│   │       └── comment_section.dart
│   ├── create_plan/
│   │   ├── view_model/
│   │   │   └── create_plan_view_model.dart
│   │   └── widgets/
│   │       ├── create_plan_screen.dart
│   │       ├── step_one_content.dart
│   │       ├── step_two_content.dart
│   │       └── step_three_content.dart
│   └── profile/
│       ├── view_model/
│       │   └── profile_view_model.dart
│       └── widgets/
│           ├── profile_screen.dart
│           └── profile_info.dart
├── config/
│   ├── dependencies.dart
│   └── environment.dart
├── routing/
│   └── router.dart
├── utils/
│   ├── command.dart
│   ├── result.dart
│   └── extensions.dart
├── main.dart
├── main_development.dart
└── main_staging.dart
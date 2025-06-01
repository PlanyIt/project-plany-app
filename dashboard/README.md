# Plany Admin Dashboard

A modern web dashboard for managing the Plany application data.

## Overview

This dashboard provides an administrative interface to manage users, categories, plans, and other data for the Plany application. Built with Flutter Web, it connects to the same backend API as the mobile application.

## Features

- **Authentication**: Secure login with Firebase
- **User Management**: View, search, and manage user accounts
- **Category Management**: Create, edit, and delete plan categories
- **Plan Management**: Review, edit, and moderate user-created plans
- **Analytics**: View usage statistics and engagement metrics
- **Responsive Design**: Works on desktop and tablet devices

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project configuration
- Backend API access

### Environment Setup

1. Create a `.env` file in the project root with:

```
API_URL=https://your-backend-api-url.com
```

2. Run `flutter pub get` to install dependencies

3. Start the app with `flutter run -d chrome`

## Deployment

To build for production:

```
flutter build web --release
```

The output will be in the `build/web` directory, which can be deployed to any web hosting service.

## Architecture

This dashboard follows a clean architecture pattern with:

- **Providers**: State management using Provider package
- **Services**: API communication and business logic
- **Models**: Data structures shared with the backend
- **Widgets**: Reusable UI components

## Design Philosophy

The dashboard implements a modern, clean design with:

- Intuitive navigation
- Consistent color scheme aligned with the Plany brand
- Data-focused UI with powerful filtering and sorting
- Responsive layouts that work across device sizes

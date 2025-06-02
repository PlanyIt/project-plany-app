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

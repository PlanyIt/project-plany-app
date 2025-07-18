src/
├── app.module.ts
├── auth/
├── user/
├── plan/
├── step/
├── comment/
├── category/
└── infrastructure/

# Plany Backend

Backend API for **Plany**, a collaborative platform for sharing and discovering outing plans. Built with [NestJS](https://nestjs.com/) and MongoDB, it provides a robust, secure, and scalable REST API for users, plans, steps, comments, and categories.

---

## Features

- **User Management**: Registration, authentication (JWT), profile, premium status, followers/following, secure password (Argon2)
- **Plans**: CRUD, steps, categories, favorites
- **Steps**: Ordered steps (activities/places), geolocation, images, cost, duration
- **Comments**: Hierarchical, likes, replies, moderation
- **Categories**: Organize plans by category
- **Security**: Helmet, rate limiting, NoSQL injection protection, DTO validation, CORS
- **Testing**: Unit and e2e tests with Jest

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+ recommended)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- [MongoDB](https://www.mongodb.com/) (local or cloud)

### Installation

```bash
cd back
npm install
# or

```

### Environment Variables

Create a `.env` file in `/back` with:

```
MONGO_URI=mongodb://localhost:27017/plany
JWT_SECRET=your_jwt_secret
JWT_SECRET_AT=your_access_token_secret
JWT_SECRET_RT=your_refresh_token_secret
JWT_AT_EXPIRES_IN=15m
JWT_RT_EXPIRES_IN=30d
CORS_ORIGIN=https://plany.app,https://admin.plany.app
PORT=3000
```

> You can use `.env.local` for local overrides.

---

## Running the Server

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

API available at `http://localhost:3000` by default.

---

## Database Setup & Seeding

Initialize and seed the database:

```bash
npm run db:init    # Create collections
npm run db:seed    # Seed demo data
npm run db:reset   # Reset and reseed all data
```

---

## API Overview

- **Base URL:** `/api`
- **Authentication:** JWT (access & refresh tokens)
- **Main Endpoints:**
  - `/api/auth` - Login, register, refresh, logout, change password
  - `/api/users` - User CRUD, profile, stats, followers, following, favorites
  - `/api/plans` - Plan CRUD, favorites, user plans
  - `/api/steps` - Step CRUD
  - `/api/comments` - Comment CRUD, likes, replies
  - `/api/categories` - Category CRUD

---

## Testing

```bash
# Unit tests
npm run test

# End-to-end tests
npm run test:e2e

# Test coverage
npm run test:cov
```

---

## Security

- DTO validation with `class-validator`
- Helmet for HTTP headers
- Rate limiting (1000 req/15min/IP)
- NoSQL injection sanitization
- CORS configuration

---

## Project Structure

```
src/
  ├── app.module.ts
  ├── auth/
  ├── user/
  ├── plan/
  ├── step/
  ├── comment/
  ├── category/
  └── common/
```

---

## Useful Commands

- `npm run start:dev` — Start in watch mode
- `npm run db:reset` — Reset and seed the database
- `npm run test` — Run all tests

---

## License

MIT

---

## Authors

- Plany Team

---

## Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Jest Testing](https://jestjs.io/)

---

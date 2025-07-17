<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://coveralls.io/github/nestjs/nest?branch=master" target="_blank"><img src="https://coveralls.io/repos/github/nestjs/nest/badge.svg?branch=master#9" alt="Coverage" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

# Plany Backend

This is the backend API for **Plany**, a collaborative platform for sharing and discovering outing plans. Built with [NestJS](https://nestjs.com/) and MongoDB, it provides a robust, secure, and scalable REST API for managing users, plans, steps, comments, and categories.

---

## Features

- **User Management**: Registration, authentication (JWT), profile, premium status, followers/following, and secure password handling (Argon2).
- **Plans**: Create, update, delete, and retrieve outing plans with steps, categories, and favorites.
- **Steps**: Each plan consists of ordered steps (activities/places), with geolocation, images, cost, and duration.
- **Comments**: Hierarchical comments system with likes, replies, and moderation.
- **Categories**: Organize plans by category (e.g., Weekend, Culture, Gastronomy).
- **Security**: Helmet, rate limiting, NoSQL injection protection, DTO validation, and CORS.
- **Testing**: Unit and e2e tests with Jest.

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+ recommended)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- [MongoDB](https://www.mongodb.com/) (local or cloud instance)

### Installation

```bash
npm install
# or
yarn install
```

### Environment Variables

Create a `.env` file at the root of `/back` with the following variables:

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

> **Note:** You can use `.env.local` for local overrides.

---

## Running the Server

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

The API will be available at `http://localhost:3000` by default.

---

## Database Setup & Seeding

Initialize and seed the database with demo data:

```bash
npm run db:init    # Create collections if needed
npm run db:seed    # Seed demo users, plans, steps, categories, comments
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

> See the [OpenAPI/Swagger documentation](#) (if enabled) for full endpoint details.

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
  └── infrastructure/
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

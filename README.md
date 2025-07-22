# Plany Project

Plany is a full-stack application for collaborative planning, featuring a Flutter front-end and a NestJS/MongoDB back-end. This monorepo contains both the mobile app and the REST API server.

---

## Project Structure

```
project-plany-app/
├── back/   # NestJS REST API (Node.js, MongoDB)
├── front/  # Flutter mobile app
└── ...     # CI/CD, configs, docs
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone <repo-url>
cd project-plany-app
```

### 2. Setup the Backend

See [`back/README.md`](./back/README.md) for full details.

- Install dependencies: `cd back && npm install`
- Configure environment: create `.env` in `/back` (see template in backend README)
- Start dev server: `npm run start:dev`
- Seed database: `npm run seed:dev`
- Run tests: `npm run test` (unit), `npm run test:e2e` (e2e)

### 3. Setup the Frontend

See [`front/README.md`](./front/README.md) for full details.

- Install Flutter SDK
- Install dependencies: `cd front && flutter pub get`
- Configure environment: create `.env` in `/front` (see frontend README)
- Start app: `flutter run`
- Run tests: `flutter test`

---

## CI/CD

- Automated builds and tests via Codemagic (`codemagic.yaml`)
- Linting, code coverage, and SonarCloud integration

---

## Documentation

- [Backend README](./back/README.md): API, setup, database, testing
- [Frontend README](./front/README.md): Flutter app, setup, environment, testing

---

## License

MIT

---

## Authors

Plany Team

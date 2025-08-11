# OrdersAPI TypeScript

A modern GraphQL API built with TypeScript, Prisma ORM, and Apollo Server for learning backend development patterns.

## Overview

This project demonstrates building a type-safe API using modern TypeScript tools and practices. It's designed as a learning exercise to understand the integration between database schema management, type-safe ORM operations, and GraphQL API development.

## Technology Stack

- **TypeScript** - Static typing for JavaScript
- **Prisma** - Type-safe ORM and database client
- **Apollo Server** - GraphQL server implementation
- **PostgreSQL/MySQL** - SQL database (to be determined)

## Current Status

### ✅ Completed
- Project structure setup
- TypeScript configuration
- Prisma ORM integration
- Apollo Server GraphQL setup
- Database schema design
- Basic resolver implementation

### 📋 Learning Objectives
- Understanding TypeScript fundamentals for backend development
- Mastering Prisma ORM concepts and type safety
- Learning Apollo Server and GraphQL patterns
- Implementing end-to-end type safety from database to client

## Project Structure

```
OrdersAPI_TS/
├── prisma/
│   ├── schema.prisma          # Database schema
│   └── migrations/            # Database migrations
├── src/
│   ├── resolvers/             # GraphQL resolvers
│   ├── schema/                # GraphQL type definitions
│   ├── utils/                 # Utilities and context
│   ├── server.ts              # Apollo server setup
│   └── index.ts               # Entry point
├── package.json
├── tsconfig.json
└── CLAUDE.md                  # Learning notes and progress
```

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up your database connection in `.env`

3. Run Prisma migrations:
   ```bash
   npx prisma migrate dev
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

## Development Notes

This project serves as a practical learning exercise transitioning from Python/FastAPI to modern TypeScript backend development. The focus is on understanding type safety, ORM patterns, and GraphQL API design.

For detailed learning progress and implementation notes, see [CLAUDE.md](./CLAUDE.md).
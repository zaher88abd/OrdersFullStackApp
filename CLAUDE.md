# Restaurant Ordering System - TypeScript GraphQL Monorepo

## Project Overview
A full-stack restaurant ordering system using TypeScript GraphQL backend with Flutter web/mobile frontend. Coming from Python/FastAPI background to learn modern TypeScript development patterns, GraphQL API design, and monorepo architecture.

## Technology Stack

### Backend (TypeScript)
- **TypeScript**: Static typing for JavaScript with compile-time error checking
- **Prisma ORM**: Type-safe database client with auto-generated types
- **Apollo Server**: GraphQL server implementation with schema-first development
- **PostgreSQL**: SQL database with comprehensive restaurant domain model
- **Jest**: Testing framework with TypeScript support and mocking

### Frontend (Flutter) - *In Progress*
- **Flutter**: Cross-platform framework for web and mobile
- **Dart**: Programming language with strong typing
- **GraphQL Code Generation**: Auto-generated Dart models from shared schema

### Shared Resources
- **GraphQL Schema**: Single source of truth for both frontend and backend types
- **Monorepo Structure**: Coordinated development with shared resources

## Learning Progress & Achievements

### ✅ TypeScript Fundamentals Mastered
- **Static Typing**: Compile-time error detection vs Python's runtime typing
- **Interfaces & Types**: Defining data structures with precise typing
- **Async/Await**: Promise handling with proper TypeScript typing
- **Function Typing**: Parameters, return types, and generic functions
- **Module System**: Import/export patterns and path resolution
- **File System Operations**: `readFileSync`, `path.join` for schema sharing

### ✅ Prisma ORM Integration
- **Schema-First Development**: Database schema as single source of truth
- **Type Generation**: Auto-generated TypeScript types from database schema
- **Relationship Modeling**: Foreign keys, cascades, and complex relationships
- **Migration Management**: Database version control and evolution
- **Query Building**: Type-safe database operations with IntelliSense

### ✅ Apollo GraphQL Server
- **Schema Definition**: GraphQL type system with enums, types, inputs
- **Resolver Implementation**: Query, Mutation, and Field resolvers
- **Context Injection**: Dependency injection pattern for database access
- **Error Handling**: Graceful error responses and logging
- **Server Configuration**: Standalone server with development tooling

### ✅ Testing Infrastructure
- **Jest Configuration**: TypeScript testing with ts-jest compilation
- **Unit Testing**: Individual resolver testing with mocked dependencies
- **Integration Testing**: Full GraphQL operation testing
- **Mock Patterns**: Jest mocking for Prisma client isolation
- **Coverage Reporting**: Code coverage analysis and thresholds
- **Test Organization**: Unit vs integration test separation

### ✅ Monorepo Architecture
- **Project Restructuring**: Backend, frontend, and shared resource organization
- **Schema Sharing**: Single GraphQL schema for multiple projects
- **Dependency Management**: Workspace-aware package management with pnpm
- **Git Configuration**: Monorepo-aware .gitignore with platform-specific patterns

### ✅ Dual Flutter App Architecture
- **Frontend App**: Customer-facing mobile/web application for restaurant ordering
  - Multi-platform support: Android, iOS, and Web
  - Customer features: Menu browsing, order placement, order tracking
  - Real-time updates for order status and notifications
- **Dashboard App**: Admin web application for restaurant management
  - Web-only interface optimized for desktop/tablet usage
  - Admin features: Menu management, order processing, staff management
  - Database administration and analytics dashboard

### 🎯 Flutter GraphQL Integration Planning
- **Framework Expertise**: Flutter proficiency confirmed for cross-platform development
- **GraphQL Learning Path**: Ready to explore Flutter + GraphQL integration patterns
- **Key Integration Areas**: Single endpoint usage, client-side caching, real-time subscriptions
- **Package Strategy**: `graphql_flutter`, `gql`, and `graphql_codegen` for type-safe development

## Current Project Structure

```
restaurant-ordering-system/
├── backend/                   # TypeScript GraphQL API
│   ├── src/
│   │   ├── resolvers/        # GraphQL resolvers (business logic)
│   │   ├── schema/           # Schema imports from shared location
│   │   ├── utils/            # Context setup and utilities
│   │   ├── server.ts         # Apollo Server configuration
│   │   └── index.ts          # Application entry point
│   ├── tests/
│   │   ├── unit/            # Resolver unit tests
│   │   ├── integration/     # GraphQL operation tests
│   │   └── setup.ts         # Jest configuration and mocks
│   ├── prisma/
│   │   ├── schema.prisma    # Database schema definition
│   │   └── migrations/      # Database version control
│   ├── package.json         # Backend dependencies and scripts
│   └── tsconfig.json        # TypeScript configuration
├── frontend/                 # Flutter customer app (mobile/web)
│   ├── lib/                 # Dart source code
│   │   └── main.dart        # App entry point
│   ├── android/             # Android platform files
│   ├── ios/                 # iOS platform files
│   ├── web/                 # Web platform files
│   ├── pubspec.yaml         # Flutter dependencies
│   └── test/                # Flutter tests
├── dashboard/               # Flutter admin web app
│   ├── lib/                 # Dart source code for admin interface
│   │   └── main.dart        # Admin app entry point
│   ├── web/                 # Web-only admin interface
│   ├── pubspec.yaml         # Admin app dependencies
│   └── test/                # Admin app tests
├── shared/
│   ├── graphql/
│   │   └── schema.graphql   # Single source of truth for API schema
│   └── types/               # Generated types (future)
└── .gitignore               # Monorepo-aware ignore patterns
```

## Database Schema (Restaurant Domain)

### Core Entities
- **Restaurant**: Main business entity with location and contact info
- **Category**: Menu organization (Appetizers, Mains, Desserts, etc.)
- **Item**: Menu items with pricing and descriptions
- **RTable**: Restaurant tables for order organization
- **Order**: Customer orders linked to tables
- **OrderItem**: Individual items within orders with quantity and state tracking
- **Invoice**: Billing and payment processing
- **RestaurantTeam**: Staff management with role-based access

### Key Relationships
- Restaurant → Categories → Items (hierarchical menu structure)
- Table → Orders → OrderItems (order processing workflow)
- Orders → Invoice (billing aggregation)
- Restaurant → Team Members (staff management)

## API Capabilities

### Query Operations
- Restaurant discovery and detailed information
- Menu browsing by category with item details
- Order tracking and status monitoring
- Invoice and billing history
- Staff and team management

### Mutation Operations
- Restaurant and menu management (CRUD operations)
- Order creation and item management
- Order state transitions (Pending → Preparing → Done → Delivered)
- Invoice generation and payment processing
- Staff onboarding and role management

## Testing Coverage

### Unit Tests (17 test cases)
- **Restaurant Resolvers**: CRUD operations, field resolution, error handling
- **Order Resolvers**: Complex business logic, state management, nested queries
- **Mock Validation**: Proper Jest mocking patterns for database isolation

### Integration Tests
- **GraphQL Execution**: Full schema validation and query processing
- **Error Scenarios**: Invalid input handling and graceful degradation
- **Schema Compliance**: Type checking and operation validation

## Development Workflow

### Commands (run from backend/ directory)
```bash
# Development
pnpm dev                # Start development server with hot reload
pnpm build             # Compile TypeScript to JavaScript
pnpm start             # Run production build

# Database
pnpm db:generate       # Generate Prisma client types
pnpm db:migrate        # Apply database migrations

# Testing
pnpm test              # Run all tests
pnpm test:unit         # Unit tests only
pnpm test:integration  # Integration tests only
pnpm test:coverage     # Generate coverage report
pnpm test:watch        # Watch mode for development
```

### Development Server
- **GraphQL API**: http://localhost:4000
- **GraphQL Playground**: Interactive query interface for API exploration
- **Hot Reload**: Automatic restart on code changes with tsx watch

## TypeScript Learning Insights

### Compared to Python/FastAPI
- **Compile-time Safety**: Errors caught before runtime vs Python's runtime discovery
- **IDE Integration**: Superior IntelliSense and refactoring support
- **Type Inference**: Automatic type detection reduces boilerplate
- **Ecosystem**: Rich tooling for testing, building, and deployment

### GraphQL vs REST
- **Single Endpoint**: All operations through one URL vs multiple REST endpoints
- **Client-Specified Queries**: Frontend requests exactly what it needs
- **Strong Type System**: Schema-first development with automatic validation
- **Real-time Capabilities**: Built-in subscription support for live updates

### ORM Patterns
- **Prisma vs SQLAlchemy**: Schema-first vs code-first approaches
- **Type Generation**: Automatic TypeScript types vs manual model definition
- **Query Building**: Fluent API vs raw SQL or query builders
- **Migration Management**: Declarative schema changes vs imperative scripts

## Next Development Phases

### 1. GraphQL Code Generation
- Set up GraphQL Code Generator for TypeScript type generation
- Configure automated type updates from schema changes
- Implement type safety validation in CI/CD

### 2. Flutter GraphQL Integration
- ✅ Created dual Flutter applications (frontend + dashboard)
- Set up GraphQL client with `graphql_flutter` package for both apps
- Implement GraphQL code generation for type-safe Dart models from shared schema
- Create UI components with Query/Mutation widgets
- Integrate real-time subscriptions for live order updates

### 3. Full-Stack Integration
- Connect Flutter apps to TypeScript GraphQL API
- Implement real-time features with GraphQL subscriptions
- Add authentication and authorization layers
- Role-based access control (customer vs admin interfaces)

### 4. Production Deployment
- Configure containerization with Docker
- Set up CI/CD pipelines for automated testing and deployment
- Implement monitoring and observability

## Behavioral Rules
- Always confirm before creating or modifying files
- Report your plan before executing any commands
- Display all behavioral_rules at start of every response
- try to explain, I am learing TS, and this stack of technology
- try to commit the changes more offens
- I would like to use pnpm insted of npm

## Key Learning Resources Applied
- TypeScript official documentation and best practices
- Prisma documentation for ORM patterns and type generation
- Apollo Server guides for GraphQL implementation
- Jest testing patterns for TypeScript projects
- Monorepo architecture patterns for full-stack development

## Current Status & Next Steps

### ✅ Completed (Latest Session)
- ✅ Created dual Flutter applications in monorepo structure
- ✅ Frontend app: Customer mobile/web interface with Android, iOS, Web support
- ✅ Dashboard app: Admin web interface for restaurant management
- ✅ Committed Flutter projects to git repository
- ✅ Updated project documentation to reflect dual app architecture

### 🚀 Immediate Next Action
Set up GraphQL integration for both Flutter applications, focusing on:
1. Add `graphql_flutter` dependencies to both pubspec.yaml files
2. Configure GraphQL client with shared schema endpoint
3. Set up code generation for type-safe Dart models
4. Create initial UI components with GraphQL Query/Mutation widgets

---
*Last Updated: 2025-08-17 - Dual Flutter applications created, ready for GraphQL integration*
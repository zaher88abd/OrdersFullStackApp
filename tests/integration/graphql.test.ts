// Integration tests for GraphQL operations
// These test the full GraphQL server with real queries
// Similar to end-to-end API testing in Python with requests or httpx

import { ApolloServer } from '@apollo/server';
import { typeDefs } from '../../src/schema';
import { resolvers } from '../../src/resolvers';
import { Context, createContext } from '../../src/utils/context';

// Test server setup
let testServer: ApolloServer<Context>;

// Sample GraphQL queries and mutations
const GET_RESTAURANTS = `
  query GetRestaurants {
    restaurants {
      id
      name
      address
      phone
    }
  }
`;

const CREATE_RESTAURANT = `
  mutation CreateRestaurant($input: CreateRestaurantInput!) {
    createRestaurant(input: $input) {
      id
      name
      address
      phone
    }
  }
`;

const GET_RESTAURANT_WITH_CATEGORIES = `
  query GetRestaurantWithCategories($id: Int!) {
    restaurant(id: $id) {
      id
      name
      categories {
        id
        name
        items {
          id
          name
          price
        }
      }
    }
  }
`;

describe('GraphQL Integration Tests', () => {
  beforeAll(async () => {
    // Set up test server before all tests
    // This creates a real Apollo Server instance for testing
    testServer = new ApolloServer<Context>({
      typeDefs,
      resolvers,
      // Disable introspection and playground for testing
      introspection: false,
    });

    await testServer.start();
  });

  afterAll(async () => {
    // Clean up after all tests
    await testServer?.stop();
  });

  describe('Restaurant Operations', () => {
    test('should execute restaurants query', async () => {
      // This tests the complete GraphQL execution pipeline
      // From query parsing → validation → execution → response formatting
      
      const response = await testServer.executeOperation(
        {
          query: GET_RESTAURANTS,
        },
        {
          contextValue: createContext(), // Use mocked context
        }
      );

      // Check that the operation succeeded
      expect(response.body.kind).toBe('single');
      
      if (response.body.kind === 'single') {
        expect(response.body.singleResult.errors).toBeUndefined();
        expect(response.body.singleResult.data).toBeDefined();
        expect(response.body.singleResult.data?.restaurants).toBeDefined();
      }
    });

    test('should execute createRestaurant mutation', async () => {
      // Test mutation execution with variables
      // This shows how GraphQL handles input validation and type checking
      
      const variables = {
        input: {
          name: 'Test Restaurant',
          address: '123 Test St',
          phone: '555-0123',
        },
      };

      const response = await testServer.executeOperation(
        {
          query: CREATE_RESTAURANT,
          variables,
        },
        {
          contextValue: createContext(),
        }
      );

      expect(response.body.kind).toBe('single');
      
      if (response.body.kind === 'single') {
        expect(response.body.singleResult.errors).toBeUndefined();
        expect(response.body.singleResult.data?.createRestaurant).toBeDefined();
      }
    });

    test('should handle invalid input gracefully', async () => {
      // Test GraphQL input validation
      // This shows how TypeScript + GraphQL catches type errors
      
      const invalidVariables = {
        input: {
          name: '', // Invalid: empty string
          address: '123 Test St',
          // phone is missing (required field)
        },
      };

      const response = await testServer.executeOperation(
        {
          query: CREATE_RESTAURANT,
          variables: invalidVariables,
        },
        {
          contextValue: createContext(),
        }
      );

      // Expect GraphQL validation errors
      expect(response.body.kind).toBe('single');
      
      if (response.body.kind === 'single') {
        // Should have validation errors due to missing required field
        expect(response.body.singleResult.errors).toBeDefined();
      }
    });
  });

  describe('Nested Query Operations', () => {
    test('should execute nested restaurant query with relationships', async () => {
      // Test GraphQL's nested data fetching capabilities
      // This demonstrates field resolvers working together
      
      const variables = { id: 1 };

      const response = await testServer.executeOperation(
        {
          query: GET_RESTAURANT_WITH_CATEGORIES,
          variables,
        },
        {
          contextValue: createContext(),
        }
      );

      expect(response.body.kind).toBe('single');
      
      if (response.body.kind === 'single') {
        expect(response.body.singleResult.errors).toBeUndefined();
        
        const restaurant = response.body.singleResult.data?.restaurant as any;
        if (restaurant) {
          // Verify nested structure is properly resolved
          expect(restaurant).toHaveProperty('id');
          expect(restaurant).toHaveProperty('name');
          expect(restaurant).toHaveProperty('categories');
          
          // If categories exist, they should have the proper structure
          if (restaurant.categories && restaurant.categories.length > 0) {
            expect(restaurant.categories[0]).toHaveProperty('id');
            expect(restaurant.categories[0]).toHaveProperty('name');
            expect(restaurant.categories[0]).toHaveProperty('items');
          }
        }
      }
    });
  });

  describe('Error Handling', () => {
    test('should handle database errors gracefully', async () => {
      // Test how GraphQL handles resolver errors
      // This simulates database connection issues
      
      // Create a server with a context that will cause database errors
      const errorContext = {
        prisma: {
          restaurant: {
            findMany: jest.fn().mockRejectedValue(new Error('Database connection failed')),
          },
        },
      } as any;

      const response = await testServer.executeOperation(
        {
          query: GET_RESTAURANTS,
        },
        {
          contextValue: errorContext,
        }
      );

      expect(response.body.kind).toBe('single');
      
      if (response.body.kind === 'single') {
        // Should have errors due to database failure
        expect(response.body.singleResult.errors).toBeDefined();
        expect(response.body.singleResult.errors?.[0].message).toContain('Database connection failed');
      }
    });

    test('should validate required arguments', async () => {
      // Test GraphQL argument validation
      const INVALID_QUERY = `
        query GetRestaurant {
          restaurant {
            id
            name
          }
        }
      `;

      const response = await testServer.executeOperation(
        {
          query: INVALID_QUERY,
        },
        {
          contextValue: createContext(),
        }
      );

      expect(response.body.kind).toBe('single');
      
      if (response.body.kind === 'single') {
        // Should have validation errors due to missing required argument (id)
        expect(response.body.singleResult.errors).toBeDefined();
      }
    });
  });
});
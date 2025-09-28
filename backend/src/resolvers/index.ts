// Main resolvers index - combines all resolver modules
// TypeScript's import system is similar to Python's, but with different syntax

import { restaurantResolvers } from './restaurant';
import { categoryResolvers } from './category';
import { itemResolvers } from './item';
import { tableResolvers } from './table';
import { orderResolvers } from './order';
import { orderItemResolvers } from './orderItem';
import { invoiceResolvers } from './invoice';
import { teamResolvers } from './team';
import { authResolvers } from './auth';
import { Context } from '../utils/context';

// This function merges all resolvers into a single object
// The spread operator (...) is like Python's dict unpacking
export const resolvers = {
  Query: {
    // Spread all Query resolvers from different modules
    ...restaurantResolvers.Query,
    ...categoryResolvers.Query,
    ...itemResolvers.Query,
    ...tableResolvers.Query,
    ...orderResolvers.Query,
    ...orderItemResolvers.Query,
    ...invoiceResolvers.Query,
    ...teamResolvers.Query,
    ...authResolvers.Query,

    // Test resolver to verify Sentry error reporting
    testSentryError: () => {
      throw new Error('This is a test error for Sentry integration');
    },

    // More realistic error scenarios for testing
    testDatabaseError: async (parent: any, args: any, context: Context) => {
      // Simulate a database connection error
      throw new Error('Database connection timeout - unable to connect to PostgreSQL server');
    },

    testValidationError: async (parent: any, { input }: { input: { email: string } }, context: Context) => {
      // Simulate validation error with user data
      if (!input.email || !input.email.includes('@')) {
        const error = new Error('Invalid email format provided');
        error.name = 'ValidationError';
        throw error;
      }
      return 'Email is valid';
    },

    testAuthError: async (parent: any, args: any, context: Context) => {
      // Simulate authentication error
      const error = new Error('Unauthorized: Invalid or expired authentication token');
      error.name = 'AuthenticationError';
      throw error;
    },

    testSentryCapture: async (parent: any, args: any, context: Context) => {
      // Use the exact Sentry code you provided
      const Sentry = require("@sentry/node");

      try {
        // This will throw a ReferenceError since foo() is not defined
        foo();
      } catch (e) {
        Sentry.captureException(e);
        // Return the error message so you can see it was captured
        return `Error captured by Sentry: ${e.message}`;
      }
    },
  },
  
  Mutation: {
    // Spread all Mutation resolvers from different modules
    ...restaurantResolvers.Mutation,
    ...categoryResolvers.Mutation,
    ...itemResolvers.Mutation,
    ...tableResolvers.Mutation,
    ...orderResolvers.Mutation,
    ...orderItemResolvers.Mutation,
    ...invoiceResolvers.Mutation,
    ...teamResolvers.Mutation,
    ...authResolvers.Mutation,
  },

  // Type resolvers for field-level resolution
  // These handle nested data fetching (like foreign key relationships)
  Restaurant: restaurantResolvers.Restaurant,
  Category: categoryResolvers.Category,
  Item: itemResolvers.Item,
  RTable: tableResolvers.RTable,
  Order: orderResolvers.Order,
  OrderItem: orderItemResolvers.OrderItem,
  Invoice: invoiceResolvers.Invoice,
  RestaurantTeam: teamResolvers.RestaurantTeam,
};
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
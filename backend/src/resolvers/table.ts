import { Context } from '../utils/context';

// This resolver handles restaurant table operations
// In TypeScript, we define the shape of our resolver functions with typed parameters
export const tableResolvers = {
  Query: {
    // async/await pattern for database operations - similar to Python's async functions
    rtables: async (
      parent: any, // Parent object from GraphQL (not used in root queries)
      { restaurantId }: { restaurantId: number }, // Destructured arguments with TypeScript types
      context: Context // Our custom context type containing Prisma client
    ) => {
      // Prisma's findMany is like a SELECT query with JOIN includes
      return context.prisma.rTable.findMany({
        where: { restaurantId },
        include: {
          orders: true, // This includes related orders (like a JOIN)
          restaurant: true,
        },
      });
    },
  },

  Mutation: {
    createRTable: async (
      parent: any,
      { input }: { input: { name: string; restaurantId: number } },
      context: Context
    ) => {
      return context.prisma.rTable.create({
        data: input, // Prisma automatically validates against your schema
        include: {
          orders: true,
          restaurant: true,
        },
      });
    },

    deleteRTable: async (parent: any, { id }: { id: number }, context: Context) => {
      try {
        await context.prisma.rTable.delete({
          where: { id },
        });
        return true;
      } catch (error) {
        // In TypeScript, error handling is explicit - we return false on failure
        return false;
      }
    },
  },

  // Field resolvers - these run when a client requests related data
  // This is GraphQL's solution to the N+1 query problem
  RTable: {
    orders: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.order.findMany({
        where: { tableId: parent.id },
      });
    },

    restaurant: async (parent: { restaurantId: number }, args: any, context: Context) => {
      return context.prisma.restaurant.findUnique({
        where: { id: parent.restaurantId },
      });
    },
  },
};
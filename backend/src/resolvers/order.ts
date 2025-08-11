import { Context } from '../utils/context';

// Order resolvers handle the core ordering logic
// TypeScript interfaces help us define exact shapes for our data
export const orderResolvers = {
  Query: {
    orders: async (
      parent: any,
      { tableId }: { tableId?: number }, // Optional parameter using TypeScript's ? syntax
      context: Context
    ) => {
      // If tableId is provided, filter by it; otherwise return all orders
      const whereClause = tableId ? { tableId } : {};
      
      return context.prisma.order.findMany({
        where: whereClause,
        include: {
          orderItems: {
            include: {
              item: true, // Nested include - gets item details for each order item
            },
          },
          rtable: true,
          invoice: true,
        },
        orderBy: {
          createdAt: 'desc', // Most recent orders first
        },
      });
    },

    order: async (parent: any, { id }: { id: number }, context: Context) => {
      return context.prisma.order.findUnique({
        where: { id },
        include: {
          orderItems: {
            include: {
              item: true,
            },
          },
          rtable: true,
          invoice: true,
        },
      });
    },
  },

  Mutation: {
    createOrder: async (
      parent: any,
      { input }: { input: { tableId: number } },
      context: Context
    ) => {
      // Prisma handles the DateTime creation automatically with @default(now())
      return context.prisma.order.create({
        data: {
          tableId: input.tableId,
          // invoiceId is optional (nullable in schema), so we don't set it initially
        },
        include: {
          orderItems: true,
          rtable: true,
          invoice: true,
        },
      });
    },

    deleteOrder: async (parent: any, { id }: { id: number }, context: Context) => {
      try {
        // Cascade delete will handle related orderItems due to schema definition
        await context.prisma.order.delete({
          where: { id },
        });
        return true;
      } catch (error) {
        console.error('Error deleting order:', error);
        return false;
      }
    },
  },

  // Field resolvers for nested data fetching
  Order: {
    orderItems: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.orderItem.findMany({
        where: { orderId: parent.id },
        include: {
          item: true, // Include item details for each order item
        },
      });
    },

    rtable: async (parent: { tableId: number }, args: any, context: Context) => {
      return context.prisma.rTable.findUnique({
        where: { id: parent.tableId },
      });
    },

    invoice: async (parent: { invoiceId: number | null }, args: any, context: Context) => {
      // Handle nullable invoice relationship
      if (!parent.invoiceId) return null;
      
      return context.prisma.invoice.findUnique({
        where: { id: parent.invoiceId },
      });
    },
  },
};
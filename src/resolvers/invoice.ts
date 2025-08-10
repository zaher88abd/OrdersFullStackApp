import { Context } from '../utils/context';

// Invoice resolvers handle billing and payment processing
// This shows more complex business logic in TypeScript resolvers
export const invoiceResolvers = {
  Query: {
    invoices: async (
      parent: any,
      { restaurantId }: { restaurantId: number },
      context: Context
    ) => {
      return context.prisma.invoice.findMany({
        where: { restaurantId },
        include: {
          restaurant: true,
          orders: {
            include: {
              orderItems: {
                include: {
                  item: true, // Deep nesting for complete invoice details
                },
              },
              rtable: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc', // Most recent invoices first
        },
      });
    },
  },

  Mutation: {
    createInvoice: async (
      parent: any,
      { 
        input 
      }: { 
        input: { 
          total: number; 
          restaurantId: number; 
          orderIds: number[]; 
        } 
      },
      context: Context
    ) => {
      // This demonstrates a transaction in Prisma - all operations succeed or fail together
      // Similar to database transactions you might know from other systems
      return context.prisma.$transaction(async (prisma) => {
        // First, create the invoice
        const invoice = await prisma.invoice.create({
          data: {
            total: input.total,
            restaurantId: input.restaurantId,
          },
        });

        // Then, update all specified orders to reference this invoice
        // This is like a bulk UPDATE in SQL
        await prisma.order.updateMany({
          where: {
            id: {
              in: input.orderIds, // SQL IN clause equivalent
            },
          },
          data: {
            invoiceId: invoice.id,
          },
        });

        // Return the invoice with all related data
        return prisma.invoice.findUnique({
          where: { id: invoice.id },
          include: {
            restaurant: true,
            orders: {
              include: {
                orderItems: {
                  include: {
                    item: true,
                  },
                },
                rtable: true,
              },
            },
          },
        });
      });
    },
  },

  // Field resolvers with business logic
  Invoice: {
    restaurant: async (parent: { restaurantId: number }, args: any, context: Context) => {
      return context.prisma.restaurant.findUnique({
        where: { id: parent.restaurantId },
      });
    },

    orders: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.order.findMany({
        where: { invoiceId: parent.id },
        include: {
          orderItems: {
            include: {
              item: true,
            },
          },
          rtable: true,
        },
      });
    },
  },
};
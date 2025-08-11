import { Context } from '../utils/context';
import { OrderItemState } from '@prisma/client';

// OrderItem resolvers handle individual items within orders
// This demonstrates TypeScript enums imported from Prisma generated types
export const orderItemResolvers = {
  Query: {
    orderItems: async (
      parent: any,
      { orderId }: { orderId: number },
      context: Context
    ) => {
      return context.prisma.orderItem.findMany({
        where: { orderId },
        include: {
          order: true,
          item: true,
        },
        orderBy: {
          id: 'asc', // Order by creation sequence
        },
      });
    },
  },

  Mutation: {
    createOrderItem: async (
      parent: any,
      { 
        input 
      }: { 
        input: { 
          orderId: number; 
          itemId: number; 
          quantity: number; 
          price: number; 
        } 
      },
      context: Context
    ) => {
      // TypeScript ensures we provide all required fields
      // The state defaults to PENDING as defined in the Prisma schema
      return context.prisma.orderItem.create({
        data: {
          ...input, // Spread operator - equivalent to Python's **input
          // state will default to PENDING
          // updatedAt will be set automatically by Prisma
        },
        include: {
          order: true,
          item: true,
        },
      });
    },

    updateOrderItemState: async (
      parent: any,
      { input }: { input: { id: number; state: OrderItemState } },
      context: Context
    ) => {
      // This function updates the cooking/delivery state of an order item
      // TypeScript's enum ensures only valid states can be used
      return context.prisma.orderItem.update({
        where: { id: input.id },
        data: { 
          state: input.state,
          // updatedAt is automatically updated by Prisma's @updatedAt
        },
        include: {
          order: true,
          item: true,
        },
      });
    },

    deleteOrderItem: async (parent: any, { id }: { id: number }, context: Context) => {
      try {
        await context.prisma.orderItem.delete({
          where: { id },
        });
        return true;
      } catch (error) {
        console.error('Error deleting order item:', error);
        return false;
      }
    },
  },

  // Field resolvers for related data
  OrderItem: {
    order: async (parent: { orderId: number }, args: any, context: Context) => {
      return context.prisma.order.findUnique({
        where: { id: parent.orderId },
      });
    },

    item: async (parent: { itemId: number }, args: any, context: Context) => {
      return context.prisma.item.findUnique({
        where: { id: parent.itemId },
      });
    },
  },
};
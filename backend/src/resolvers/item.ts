import { Context } from '../utils/context';

export const itemResolvers = {
  Query: {
    items: async (parent: any, { categoryId }: { categoryId: number }, context: Context) => {
      return context.prisma.item.findMany({
        where: { categoryId },
        include: {
          orderItems: true,
          category: true,
        },
      });
    },

    item: async (parent: any, { id }: { id: number }, context: Context) => {
      return context.prisma.item.findUnique({
        where: { id },
        include: {
          orderItems: true,
          category: true,
        },
      });
    },
  },

  Mutation: {
    createItem: async (
      parent: any,
      { 
        input 
      }: { 
        input: { 
          name: string; 
          description: string; 
          image: string; 
          price: number; 
          categoryId: number 
        } 
      },
      context: Context
    ) => {
      return context.prisma.item.create({
        data: input,
        include: {
          orderItems: true,
          category: true,
        },
      });
    },

    updateItem: async (
      parent: any,
      { 
        id, 
        input 
      }: { 
        id: number; 
        input: { 
          name?: string; 
          description?: string; 
          image?: string; 
          price?: number 
        } 
      },
      context: Context
    ) => {
      return context.prisma.item.update({
        where: { id },
        data: input,
        include: {
          orderItems: true,
          category: true,
        },
      });
    },

    deleteItem: async (parent: any, { id }: { id: number }, context: Context) => {
      try {
        await context.prisma.item.delete({
          where: { id },
        });
        return true;
      } catch (error) {
        return false;
      }
    },
  },

  Item: {
    orderItems: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.orderItem.findMany({
        where: { itemId: parent.id },
      });
    },

    category: async (parent: { categoryId: number }, args: any, context: Context) => {
      return context.prisma.category.findUnique({
        where: { id: parent.categoryId },
      });
    },
  },
};
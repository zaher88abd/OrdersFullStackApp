import { Context } from '../utils/context';

export const categoryResolvers = {
  Query: {
    categories: async (
      parent: any,
      { restaurantId }: { restaurantId: number },
      context: Context
    ) => {
      return context.prisma.category.findMany({
        where: { restaurantId },
        include: {
          items: true,
          restaurant: true,
        },
      });
    },
  },

  Mutation: {
    createCategory: async (
      parent: any,
      { input }: { input: { name: string; restaurantId: number } },
      context: Context
    ) => {
      return context.prisma.category.create({
        data: input,
        include: {
          items: true,
          restaurant: true,
        },
      });
    },

    deleteCategory: async (parent: any, { id }: { id: number }, context: Context) => {
      try {
        await context.prisma.category.delete({
          where: { id },
        });
        return true;
      } catch (error) {
        return false;
      }
    },
  },

  Category: {
    items: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.item.findMany({
        where: { categoryId: parent.id },
      });
    },

    restaurant: async (parent: { restaurantId: number }, args: any, context: Context) => {
      return context.prisma.restaurant.findUnique({
        where: { id: parent.restaurantId },
      });
    },
  },
};
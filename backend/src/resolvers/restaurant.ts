import { Context } from '../utils/context';

export const restaurantResolvers = {
  Query: {
    restaurants: async (parent: any, args: any, context: Context) => {
      return context.prisma.restaurant.findMany({
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    },
    
    restaurant: async (parent: any, { id }: { id: number }, context: Context) => {
      return context.prisma.restaurant.findUnique({
        where: { id },
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    },
  },

  Mutation: {
    createRestaurant: async (
      parent: any,
      { input }: { input: { name: string; address: string; phone: string } },
      context: Context
    ) => {
      return context.prisma.restaurant.create({
        data: input,
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    },

    updateRestaurant: async (
      parent: any,
      { id, input }: { id: number; input: { name?: string; address?: string; phone?: string } },
      context: Context
    ) => {
      return context.prisma.restaurant.update({
        where: { id },
        data: input,
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    },

    deleteRestaurant: async (parent: any, { id }: { id: number }, context: Context) => {
      try {
        await context.prisma.restaurant.delete({
          where: { id },
        });
        return true;
      } catch (error) {
        return false;
      }
    },
  },

  Restaurant: {
    invoices: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.invoice.findMany({
        where: { restaurantId: parent.id },
      });
    },

    rtables: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.rTable.findMany({
        where: { restaurantId: parent.id },
      });
    },

    categories: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.category.findMany({
        where: { restaurantId: parent.id },
      });
    },

    restaurantTeam: async (parent: { id: number }, args: any, context: Context) => {
      return context.prisma.restaurantTeam.findMany({
        where: { restaurantId: parent.id },
      });
    },
  },
};
import { Context } from '../utils/context';
import { JobType } from '@prisma/client';

// RestaurantTeam resolvers handle staff management
// Shows how to work with string IDs (uuid) vs integer IDs
export const teamResolvers = {
  Query: {
    restaurantTeam: async (
      parent: any,
      { restaurantId }: { restaurantId: number },
      context: Context
    ) => {
      return context.prisma.restaurantTeam.findMany({
        where: { restaurantId },
        include: {
          restaurant: true,
        },
        orderBy: {
          jobType: 'asc', // Group by job type (MANAGER, CHEF, WAITER)
        },
      });
    },
  },

  Mutation: {
    createRestaurantTeam: async (
      parent: any,
      { 
        input 
      }: { 
        input: { 
          uuid: string; 
          name: string; 
          jobType: JobType; 
          restaurantId: number; 
        } 
      },
      context: Context
    ) => {
      return context.prisma.restaurantTeam.create({
        data: input,
        include: {
          restaurant: true,
        },
      });
    },

    deleteRestaurantTeam: async (
      parent: any,
      { uuid }: { uuid: string }, // Note: using uuid (string) as identifier, not id (number)
      context: Context
    ) => {
      try {
        await context.prisma.restaurantTeam.delete({
          where: { uuid }, // Primary key is uuid field
        });
        return true;
      } catch (error) {
        console.error('Error deleting restaurant team member:', error);
        return false;
      }
    },
  },

  // Field resolver for related restaurant data
  RestaurantTeam: {
    restaurant: async (parent: { restaurantId: number }, args: any, context: Context) => {
      return context.prisma.restaurant.findUnique({
        where: { id: parent.restaurantId },
      });
    },
  },
};
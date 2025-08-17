import { Context } from '../utils/context';
import { supabaseAdmin } from '../utils/supabase';

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
      { input }: { input: { name: string; address: string; phone: string; adminEmail: string; adminName: string } },
      context: Context
    ) => {
      try {
        // Create the restaurant
        const restaurant = await context.prisma.restaurant.create({
          data: {
            name: input.name,
            address: input.address,
            phone: input.phone,
          },
          include: {
            invoices: true,
            rtables: true,
            categories: true,
            restaurantTeam: true,
          },
        });

        // Generate a temporary UUID for the admin team member
        const tempUuid = `temp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        // Create admin team member record
        await context.prisma.restaurantTeam.create({
          data: {
            uuid: tempUuid,
            name: input.adminName,
            jobType: 'MANAGER',
            restaurantId: restaurant.id,
            isActive: false, // Will be activated when user completes signup
          },
        });

        // Send invitation email via Supabase
        let invitationSent = false;
        try {
          const { error } = await supabaseAdmin.auth.admin.inviteUserByEmail(input.adminEmail, {
            data: {
              name: input.adminName,
              role: 'admin',
              restaurantId: restaurant.id.toString(),
              restaurantName: restaurant.name,
              tempUuid: tempUuid,
            },
            redirectTo: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/complete-signup`,
          });

          if (error) {
            console.error('Failed to send invitation email:', error);
          } else {
            invitationSent = true;
          }
        } catch (emailError) {
          console.error('Error sending invitation:', emailError);
        }

        return {
          success: true,
          message: invitationSent 
            ? `Restaurant created successfully! Invitation email sent to ${input.adminEmail}`
            : `Restaurant created successfully! Please manually invite ${input.adminEmail}`,
          restaurant,
          invitationSent,
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Failed to create restaurant',
          restaurant: null,
          invitationSent: false,
        };
      }
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
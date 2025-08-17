import { Context } from '../utils/context';
import { supabaseAdmin } from '../utils/supabase';
import { requireAuth } from '../utils/auth';

interface SignUpInput {
  email: string;
  password: string;
  name?: string;
  role?: string;
}

interface SignInInput {
  email: string;
  password: string;
}

export const authResolvers = {
  Query: {
    me: async (_: any, __: any, context: Context) => {
      const user = requireAuth(context.auth);
      return {
        id: user.id,
        email: user.email,
        role: user.role,
      };
    },

    // Get user profile with restaurant team info
    userProfile: async (_: any, __: any, context: Context) => {
      const user = requireAuth(context.auth);
      
      // Find restaurant team member by matching Supabase user ID with UUID field
      const teamMember = await context.prisma.restaurantTeam.findUnique({
        where: {
          uuid: user.id // Direct match with Supabase user ID
        },
        include: {
          restaurant: true
        }
      });

      return {
        id: user.id,
        email: user.email,
        role: user.role,
        teamMember,
        restaurant: teamMember?.restaurant
      };
    }
  },

  Mutation: {
    signUp: async (_: any, { input }: { input: SignUpInput }) => {
      try {
        const { data, error } = await supabaseAdmin.auth.admin.createUser({
          email: input.email,
          password: input.password,
          user_metadata: {
            name: input.name,
            role: input.role || 'user'
          },
          email_confirm: true // Auto-confirm in development
        });

        if (error) {
          throw new Error(`Sign up failed: ${error.message}`);
        }

        return {
          success: true,
          message: 'User created successfully',
          user: {
            id: data.user?.id,
            email: data.user?.email,
            role: input.role || 'user'
          }
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Sign up failed',
          user: null
        };
      }
    },

    signIn: async (_: any, { input }: { input: SignInInput }) => {
      try {
        const { data, error } = await supabaseAdmin.auth.signInWithPassword({
          email: input.email,
          password: input.password
        });

        if (error) {
          throw new Error(`Sign in failed: ${error.message}`);
        }

        return {
          success: true,
          message: 'Signed in successfully',
          user: {
            id: data.user?.id,
            email: data.user?.email,
            role: data.user?.user_metadata?.role || 'user'
          },
          accessToken: data.session?.access_token,
          refreshToken: data.session?.refresh_token
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Sign in failed',
          user: null,
          accessToken: null,
          refreshToken: null
        };
      }
    },

    signOut: async (_: any, __: any, context: Context) => {
      try {
        const user = requireAuth(context.auth);
        
        // Sign out user from Supabase
        const { error } = await supabaseAdmin.auth.admin.signOut(user.id);
        
        if (error) {
          throw new Error(`Sign out failed: ${error.message}`);
        }

        return {
          success: true,
          message: 'Signed out successfully'
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Sign out failed'
        };
      }
    },

    // Link current logged-in user to existing restaurant team member
    linkUserToTeamMember: async (_: any, { existingUuid }: { existingUuid: string }, context: Context) => {
      try {
        const user = requireAuth(context.auth);
        
        // Check if team member exists with the existing UUID
        const existingTeamMember = await context.prisma.restaurantTeam.findUnique({
          where: { uuid: existingUuid }
        });

        if (!existingTeamMember) {
          return {
            success: false,
            message: 'Team member not found',
            teamMember: null
          };
        }

        // Update the UUID to link with current user
        const teamMember = await context.prisma.restaurantTeam.update({
          where: { uuid: existingUuid },
          data: { uuid: user.id },
          include: { restaurant: true }
        });

        return {
          success: true,
          message: 'User linked to team member successfully',
          teamMember
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Failed to link user',
          teamMember: null
        };
      }
    },

    // Complete invitation signup - links Supabase user to restaurant team
    completeInvitation: async (_: any, { tempUuid }: { tempUuid: string }, context: Context) => {
      try {
        const user = requireAuth(context.auth);
        
        // Find the team member with temporary UUID
        const teamMember = await context.prisma.restaurantTeam.findUnique({
          where: { uuid: tempUuid },
          include: { restaurant: true }
        });

        if (!teamMember) {
          return {
            success: false,
            message: 'Invalid invitation link',
            user: null,
          };
        }

        // Update the team member with the real user ID and activate
        await context.prisma.restaurantTeam.update({
          where: { uuid: tempUuid },
          data: { 
            uuid: user.id,
            isActive: true 
          }
        });

        return {
          success: true,
          message: `Welcome to ${teamMember.restaurant.name}! Your account is now active.`,
          user: {
            id: user.id,
            email: user.email,
            role: user.role,
          },
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Failed to complete invitation',
          user: null,
        };
      }
    }
  }
};
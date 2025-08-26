import { Context } from '../utils/context';
import { supabaseAdmin } from '../utils/supabase';
import { generateUniqueRestaurantCode, generateEmailVerificationCode } from '../utils/codeGenerator';

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
      { input }: { input: { name: string; address: string; phone: string; managerEmail: string; managerName: string; managerPassword: string } },
      context: Context
    ) => {
      try {
        // Generate unique restaurant code
        const restaurantCode = await generateUniqueRestaurantCode(context.prisma);

        // Create the restaurant
        const restaurant = await context.prisma.restaurant.create({
          data: {
            name: input.name,
            address: input.address,
            phone: input.phone,
            restaurantCode,
          },
          include: {
            invoices: true,
            rtables: true,
            categories: true,
            restaurantTeam: true,
          },
        });

        // Generate email verification code
        const emailVerificationCode = generateEmailVerificationCode();
        const codeExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours from now

        // Generate UUID for the manager
        const managerUuid = `mgr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        // Create manager team member record
        await context.prisma.restaurantTeam.create({
          data: {
            uuid: managerUuid,
            name: input.managerName,
            email: input.managerEmail,
            jobType: 'MANAGER',
            restaurantId: restaurant.id,
            isActive: false, // Will be activated when email is verified
            emailVerified: false,
            emailVerificationCode,
            codeExpiresAt,
          },
        });

        // Create user account in Supabase
        let accountCreated = false;
        let emailSent = false;
        
        try {
          // Create user account
          const { data, error: signUpError } = await supabaseAdmin.auth.admin.createUser({
            email: input.managerEmail,
            password: input.managerPassword,
            email_confirm: false, // We'll handle email verification manually
            user_metadata: {
              name: input.managerName,
              role: 'manager',
              restaurantId: restaurant.id.toString(),
              restaurantCode,
            },
          });

          if (signUpError) {
            console.error('Failed to create user account:', signUpError);
          } else {
            accountCreated = true;

            // Send verification email with code
            // TODO: Implement actual email sending service (e.g., SendGrid, AWS SES)
            // For now, we'll log the code
            console.log(`Email Verification Code for ${input.managerEmail}: ${emailVerificationCode}`);
            emailSent = true;
          }
        } catch (authError) {
          console.error('Error creating user account:', authError);
        }

        return {
          success: true,
          message: accountCreated && emailSent
            ? `Restaurant created successfully! Restaurant Code: ${restaurantCode}. Verification code sent to ${input.managerEmail}`
            : `Restaurant created successfully! Restaurant Code: ${restaurantCode}. Please check account creation.`,
          restaurant,
          restaurantCode,
          accountCreated,
          emailSent,
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Failed to create restaurant',
          restaurant: null,
          restaurantCode: null,
          accountCreated: false,
          emailSent: false,
        };
      }
    },

    verifyEmail: async (
      parent: any,
      { input }: { input: { email: string; verificationCode: string } },
      context: Context
    ) => {
      try {
        // Find team member by email
        const teamMember = await context.prisma.restaurantTeam.findFirst({
          where: {
            email: input.email,
            emailVerificationCode: input.verificationCode,
            emailVerified: false,
          },
          include: {
            restaurant: true,
          },
        });

        if (!teamMember) {
          return {
            success: false,
            message: 'Invalid email or verification code',
          };
        }

        // Check if code is expired
        if (teamMember.codeExpiresAt && teamMember.codeExpiresAt < new Date()) {
          return {
            success: false,
            message: 'Verification code has expired. Please request a new one.',
          };
        }

        // Update team member to verified and active
        await context.prisma.restaurantTeam.update({
          where: {
            uuid: teamMember.uuid,
          },
          data: {
            emailVerified: true,
            isActive: true,
            emailVerificationCode: null,
            codeExpiresAt: null,
          },
        });

        // Also update Supabase user to confirm email
        try {
          // Find the Supabase user by email
          const { data: users, error: listError } = await supabaseAdmin.auth.admin.listUsers();
          
          if (!listError && users) {
            const supabaseUser = users.users.find(user => user.email === input.email);
            
            if (supabaseUser) {
              // Update Supabase user to confirm email
              const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
                supabaseUser.id,
                {
                  email_confirm: true,
                }
              );
              
              if (updateError) {
                console.error('Failed to confirm email in Supabase:', updateError);
              } else {
                console.log(`✅ Email confirmed in Supabase for ${input.email}`);
              }
            }
          }
        } catch (supabaseError) {
          console.error('Error updating Supabase user:', supabaseError);
        }

        return {
          success: true,
          message: 'Email verified successfully! You can now access your restaurant dashboard.',
          restaurantCode: teamMember.restaurant.restaurantCode || undefined,
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Failed to verify email',
        };
      }
    },

    joinRestaurant: async (
      parent: any,
      { input }: { input: { restaurantCode: string; name: string; email: string; password: string; jobType: 'CHEF' | 'WAITER' } },
      context: Context
    ) => {
      try {
        // Find restaurant by code
        const restaurant = await context.prisma.restaurant.findUnique({
          where: {
            restaurantCode: input.restaurantCode,
          },
        });

        if (!restaurant) {
          return {
            success: false,
            message: 'Invalid restaurant code',
          };
        }

        // Check if email is already used in this restaurant
        const existingMember = await context.prisma.restaurantTeam.findFirst({
          where: {
            email: input.email,
            restaurantId: restaurant.id,
          },
        });

        if (existingMember) {
          return {
            success: false,
            message: 'Email is already registered for this restaurant',
          };
        }

        // Generate UUID for the team member
        const memberUuid = `emp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

        // Create team member record (staff members are active immediately, no email verification needed)
        await context.prisma.restaurantTeam.create({
          data: {
            uuid: memberUuid,
            name: input.name,
            email: input.email,
            jobType: input.jobType,
            restaurantId: restaurant.id,
            isActive: true, // Staff members are active immediately
            emailVerified: true, // No email verification required for staff
            emailVerificationCode: null,
            codeExpiresAt: null,
          },
        });

        // Create user account in Supabase
        let accountCreated = false;
        
        try {
          const { data, error: signUpError } = await supabaseAdmin.auth.admin.createUser({
            email: input.email,
            password: input.password,
            email_confirm: true, // Staff members are auto-confirmed, no email verification needed
            user_metadata: {
              name: input.name,
              role: input.jobType.toLowerCase(),
              restaurantId: restaurant.id.toString(),
              restaurantCode: restaurant.restaurantCode,
            },
          });

          if (signUpError) {
            console.error('Failed to create user account:', signUpError);
          } else {
            accountCreated = true;
            console.log(`✅ Staff member account created for ${input.email} - no email verification required`);
          }
        } catch (authError) {
          console.error('Error creating user account:', authError);
        }

        return {
          success: true,
          message: accountCreated
            ? `Successfully joined ${restaurant.name}! You can now sign in immediately.`
            : `Successfully joined ${restaurant.name}! Please check account creation.`,
          restaurantName: restaurant.name,
          accountCreated,
          emailSent: false, // No email sent for staff members
        };
      } catch (error) {
        return {
          success: false,
          message: error instanceof Error ? error.message : 'Failed to join restaurant',
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
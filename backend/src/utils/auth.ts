import jwt from 'jsonwebtoken';
import { supabase } from './supabase';

export interface AuthUser {
  id: string;
  email: string;
  role?: string;
}

export interface AuthContext {
  user?: AuthUser;
  isAuthenticated: boolean;
}

export async function verifyToken(token?: string): Promise<AuthContext> {
  if (!token) {
    return { isAuthenticated: false };
  }

  try {
    // Remove 'Bearer ' prefix if present
    const cleanToken = token.replace('Bearer ', '');
    
    // Verify JWT token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(cleanToken);
    
    if (error || !user) {
      console.error('Token verification failed:', error?.message);
      return { isAuthenticated: false };
    }

    return {
      user: {
        id: user.id,
        email: user.email || '',
        role: user.user_metadata?.role || 'user'
      },
      isAuthenticated: true
    };
  } catch (error) {
    console.error('Token verification error:', error);
    return { isAuthenticated: false };
  }
}

export function requireAuth(context: AuthContext): AuthUser {
  if (!context.isAuthenticated || !context.user) {
    throw new Error('Authentication required');
  }
  return context.user;
}

export function requireRole(context: AuthContext, requiredRole: string): AuthUser {
  const user = requireAuth(context);
  if (user.role !== requiredRole && user.role !== 'admin') {
    throw new Error(`Role '${requiredRole}' required`);
  }
  return user;
}

// Helper function to get user's restaurant team info
export async function getUserRestaurantTeam(userId: string, prisma: any) {
  return await prisma.restaurantTeam.findUnique({
    where: { uuid: userId },
    include: { restaurant: true }
  });
}

// Require user to be part of a restaurant team
export async function requireRestaurantTeam(context: any) {
  const user = requireAuth(context.auth);
  const teamMember = await getUserRestaurantTeam(user.id, context.prisma);
  
  if (!teamMember) {
    throw new Error('User must be linked to a restaurant team');
  }
  
  return { user, teamMember };
}
import { PrismaClient } from '@prisma/client';
import { AuthContext, verifyToken } from './auth';

export interface Context {
  prisma: PrismaClient;
  auth: AuthContext;
}

const prisma = new PrismaClient();

export const createContext = async ({ req }: { req: any }): Promise<Context> => {
  // Extract token from Authorization header
  const authHeader = req.headers.authorization;
  const auth = await verifyToken(authHeader);

  return {
    prisma,
    auth,
  };
};
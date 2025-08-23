import { PrismaClient } from '@prisma/client';

/**
 * Generates a unique restaurant code with 4 digits and 3 letters in any order
 * @param prisma - Prisma client instance to check for uniqueness
 * @returns Promise<string> - A unique 7-character restaurant code
 */
export async function generateUniqueRestaurantCode(prisma: PrismaClient): Promise<string> {
  let code: string;
  let isUnique = false;
  let attempts = 0;
  const maxAttempts = 100; // Prevent infinite loops

  while (!isUnique && attempts < maxAttempts) {
    code = generateRestaurantCode();
    
    // Check if code already exists in database
    const existing = await prisma.restaurant.findUnique({
      where: { restaurantCode: code }
    });
    
    isUnique = !existing;
    attempts++;
  }

  if (attempts >= maxAttempts) {
    throw new Error('Unable to generate unique restaurant code after maximum attempts');
  }

  return code!;
}

/**
 * Generates a 6-digit email verification code
 * @returns string - A 6-digit verification code
 */
export function generateEmailVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Generates a restaurant code with 4 digits and 3 letters in random order
 * @returns string - A 7-character code
 */
function generateRestaurantCode(): string {
  // Generate 4 digits
  const digits = Array.from({ length: 4 }, () => 
    Math.floor(Math.random() * 10).toString()
  );

  // Generate 3 uppercase letters
  const letters = Array.from({ length: 3 }, () =>
    String.fromCharCode(65 + Math.floor(Math.random() * 26))
  );

  // Combine and shuffle
  const combined = [...digits, ...letters];
  
  // Fisher-Yates shuffle algorithm
  for (let i = combined.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [combined[i], combined[j]] = [combined[j], combined[i]];
  }

  return combined.join('');
}
// Apollo Server setup - this is like creating your FastAPI app instance
import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';

// Import our GraphQL schema and resolvers
import { typeDefs } from './schema';
import { resolvers } from './resolvers';
import { createContext, Context } from './utils/context';

// Create Apollo Server instance
// This is similar to: app = FastAPI() in Python
export const server = new ApolloServer<Context>({
  typeDefs,    // GraphQL schema definitions (like Pydantic models + route paths)
  resolvers,   // Functions that handle each GraphQL operation (like route handlers)
  
  // Enable GraphQL Playground in development for testing queries
  // Similar to FastAPI's automatic /docs endpoint
  introspection: process.env.NODE_ENV !== 'production',
});

// Function to start the server
// TypeScript async function that returns a Promise
export async function startServer(port: number = 4000) {
  try {
    // Start the standalone server with context
    // Context is like dependency injection in FastAPI
    const { url } = await startStandaloneServer(server, {
      listen: { port },
      
      // Context function runs for every request
      // Similar to FastAPI's Depends() for database sessions
      context: async () => createContext(),
    });

    console.log(`=€ Server ready at: ${url}`);
    console.log(`=Ê GraphQL Playground available in development mode`);
    
    return { server, url };
  } catch (error) {
    console.error('L Error starting server:', error);
    throw error;
  }
}
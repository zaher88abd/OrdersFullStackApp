// Apollo Server setup - this is like creating your FastAPI app instance
import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { Sentry } from './instrument';


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

  // Add Sentry error reporting for GraphQL operations
  formatError: (error) => {
    // Capture the error in Sentry for monitoring
    Sentry.captureException(error);

    // In production, hide internal error details
    if (process.env.NODE_ENV === 'production') {
      // Only return safe error information
      return {
        message: error.message.startsWith('Database')
          ? 'An internal error occurred'
          : error.message,
        extensions: {
          code: error.extensions?.code,
        },
      };
    }

    // In development, return full error details for debugging
    return error;
  },
});

// Function to start the server
// TypeScript async function that returns a Promise
export async function startServer(port: number = 4000) {
  return Sentry.startSpan(
    {
      op: "server.startup",
      name: "Apollo Server Startup",
    },
    async () => {
      try {
        // Start the standalone server with context
        // Context is like dependency injection in FastAPI
        const { url } = await startStandaloneServer(server, {
          listen: { port },

          // Context function runs for every request
          // Similar to FastAPI's Depends() for database sessions
          context: async ({ req }) => {
            // console.log('🔥 GRAPHQL REQUEST RECEIVED:', req.body ? JSON.stringify(req.body, null, 2) : 'No body');
            return createContext({ req });
          },
        });

        console.log(`=� Server ready at: ${url}`);
        console.log(`=� GraphQL Playground available in development mode`);

        return { server, url };
      } catch (error) {
        console.error('💥 Error starting server:', error);
        Sentry.captureException(error);
        throw error;
      }
    }
  );
}
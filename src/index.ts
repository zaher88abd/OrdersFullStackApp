// Application entry point - like if __name__ == "__main__" in Python
import { startServer } from './server';

// Environment configuration with defaults
// TypeScript can infer types from default values
const PORT = parseInt(process.env.PORT || '4000', 10);

// Main function to bootstrap the application
async function main() {
  try {
    console.log('🔧 Starting OrdersAPI server...');
    console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
    
    // Start the Apollo GraphQL server
    await startServer(PORT);
    
    console.log('✅ Server started successfully!');
    console.log('');
    console.log('📝 Try these sample queries in GraphQL Playground:');
    console.log('');
    console.log('  query GetRestaurants {');
    console.log('    restaurants {');
    console.log('      id');
    console.log('      name');
    console.log('      address');
    console.log('    }');
    console.log('  }');
    console.log('');
    
  } catch (error) {
    console.error('💥 Failed to start server:', error);
    process.exit(1); // Exit with error code
  }
}

// Handle graceful shutdown
// Similar to signal handling in other server applications
process.on('SIGINT', () => {
  console.log('👋 Received SIGINT, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('👋 Received SIGTERM, shutting down gracefully...');
  process.exit(0);
});

// Start the application
// TypeScript requires explicit void for async functions that don't return values
main().catch((error) => {
  console.error('💥 Unhandled error in main:', error);
  process.exit(1);
});
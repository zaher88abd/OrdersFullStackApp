import { readFileSync } from 'fs';
import { join } from 'path';

// Import GraphQL schema from shared location
// This creates a single source of truth for both backend and frontend
const schemaPath = join(__dirname, '../../../shared/graphql/schema.graphql');
export const typeDefs = readFileSync(schemaPath, 'utf8');
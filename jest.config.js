// Jest configuration for TypeScript testing
// This is like pytest.ini or setup.cfg for Python testing

module.exports = {
  // Use ts-jest to handle TypeScript files
  preset: 'ts-jest',
  
  // Test environment (node for backend APIs)
  testEnvironment: 'node',
  
  // Root directory for tests and source files
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  
  // Test file patterns (similar to pytest discovery)
  testMatch: [
    '**/__tests__/**/*.test.ts',
    '**/*.test.ts',
    '**/*.spec.ts'
  ],
  
  // File extensions to consider
  moduleFileExtensions: ['ts', 'js', 'json'],
  
  // Transform TypeScript files
  transform: {
    '^.+\\.ts$': 'ts-jest'
  },
  
  // Coverage collection (like coverage.py in Python)
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/generated/**', // Exclude Prisma generated files
  ],
  
  // Coverage thresholds
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  },
  
  // Setup files to run before tests
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  
  // Clear mocks between tests (like pytest fixtures)
  clearMocks: true,
  
  // Verbose output
  verbose: true
};
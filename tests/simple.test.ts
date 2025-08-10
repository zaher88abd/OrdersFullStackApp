// Simple test to verify Jest setup is working
// This demonstrates basic TypeScript testing concepts

describe('Basic TypeScript Testing', () => {
  test('should demonstrate TypeScript type checking in tests', () => {
    // TypeScript ensures type safety even in tests
    const restaurant: { id: number; name: string } = {
      id: 1,
      name: 'Test Restaurant'
    };

    // Jest assertions with TypeScript support
    expect(restaurant.id).toBe(1);
    expect(restaurant.name).toBe('Test Restaurant');
    expect(typeof restaurant.id).toBe('number');
    expect(typeof restaurant.name).toBe('string');
  });

  test('should work with async functions', async () => {
    // Demonstrate async/await testing - similar to Python's asyncio testing
    const asyncFunction = async (value: number): Promise<number> => {
      return new Promise(resolve => {
        setTimeout(() => resolve(value * 2), 10);
      });
    };

    const result = await asyncFunction(5);
    expect(result).toBe(10);
  });

  test('should handle mock functions', () => {
    // Jest mocking - similar to unittest.mock in Python
    const mockFunction = jest.fn();
    
    // Configure mock return value
    mockFunction.mockReturnValue('mocked result');
    
    // Call the mock
    const result = mockFunction('test input');
    
    // Verify mock behavior
    expect(result).toBe('mocked result');
    expect(mockFunction).toHaveBeenCalledWith('test input');
    expect(mockFunction).toHaveBeenCalledTimes(1);
  });
});

// This test should run quickly to verify Jest is working
describe('Jest Environment Check', () => {
  test('Jest is properly configured', () => {
    expect(true).toBe(true);
    console.log('✅ Jest + TypeScript setup is working!');
  });
});
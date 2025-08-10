// Unit tests for restaurant resolvers
// This tests individual resolver functions in isolation
// Similar to testing individual functions in Python with unittest or pytest

import { restaurantResolvers } from '../../src/resolvers/restaurant';

// Create properly mocked Prisma client
// This creates actual Jest mock functions that we can control
const mockPrisma = {
  restaurant: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  invoice: {
    findMany: jest.fn(),
  },
} as any;

const mockContext = { prisma: mockPrisma };

// Test data - similar to fixtures in pytest
const mockRestaurant = {
  id: 1,
  name: 'Test Restaurant',
  address: '123 Test St',
  phone: '555-0123',
  invoices: [],
  rtables: [],
  categories: [],
  restaurantTeam: [],
};

const mockRestaurants = [mockRestaurant];

describe('Restaurant Resolvers', () => {
  // This describe block groups related tests, like a test class in Python
  
  beforeEach(() => {
    // Reset mocks before each test - like setUp() in unittest
    jest.clearAllMocks();
  });

  describe('Query Resolvers', () => {
    test('restaurants: should return all restaurants', async () => {
      // Arrange - set up the test data and mocks
      // This is like the "given" part of BDD testing
      mockPrisma.restaurant.findMany.mockResolvedValue(mockRestaurants);

      // Act - call the resolver function
      // This is like the "when" part of BDD testing
      const result = await restaurantResolvers.Query.restaurants(
        null, // parent
        {}, // args
        mockContext // context
      );

      // Assert - check the results
      // This is like the "then" part of BDD testing
      expect(result).toEqual(mockRestaurants);
      expect(mockPrisma.restaurant.findMany).toHaveBeenCalledWith({
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
      expect(mockPrisma.restaurant.findMany).toHaveBeenCalledTimes(1);
    });

    test('restaurant: should return a single restaurant by id', async () => {
      // Test the findUnique operation
      const restaurantId = 1;
      mockPrisma.restaurant.findUnique.mockResolvedValue(mockRestaurant);

      const result = await restaurantResolvers.Query.restaurant(
        null,
        { id: restaurantId },
        mockContext
      );

      expect(result).toEqual(mockRestaurant);
      expect(mockPrisma.restaurant.findUnique).toHaveBeenCalledWith({
        where: { id: restaurantId },
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    });

    test('restaurant: should return null for non-existent id', async () => {
      // Test edge case - similar to testing error conditions in Python
      mockPrisma.restaurant.findUnique.mockResolvedValue(null);

      const result = await restaurantResolvers.Query.restaurant(
        null,
        { id: 999 },
        mockContext
      );

      expect(result).toBeNull();
    });
  });

  describe('Mutation Resolvers', () => {
    test('createRestaurant: should create a new restaurant', async () => {
      // Test data for creation
      const input = {
        name: 'New Restaurant',
        address: '456 New St',
        phone: '555-0456',
      };

      const expectedResult = { id: 2, ...input, invoices: [], rtables: [], categories: [], restaurantTeam: [] };
      mockPrisma.restaurant.create.mockResolvedValue(expectedResult);

      const result = await restaurantResolvers.Mutation.createRestaurant(
        null,
        { input },
        mockContext
      );

      expect(result).toEqual(expectedResult);
      expect(mockPrisma.restaurant.create).toHaveBeenCalledWith({
        data: input,
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    });

    test('updateRestaurant: should update existing restaurant', async () => {
      const restaurantId = 1;
      const input = { name: 'Updated Restaurant' };
      const expectedResult = { ...mockRestaurant, ...input };

      mockPrisma.restaurant.update.mockResolvedValue(expectedResult);

      const result = await restaurantResolvers.Mutation.updateRestaurant(
        null,
        { id: restaurantId, input },
        mockContext
      );

      expect(result).toEqual(expectedResult);
      expect(mockPrisma.restaurant.update).toHaveBeenCalledWith({
        where: { id: restaurantId },
        data: input,
        include: {
          invoices: true,
          rtables: true,
          categories: true,
          restaurantTeam: true,
        },
      });
    });

    test('deleteRestaurant: should delete restaurant and return true', async () => {
      // Test successful deletion
      const restaurantId = 1;
      mockPrisma.restaurant.delete.mockResolvedValue(mockRestaurant);

      const result = await restaurantResolvers.Mutation.deleteRestaurant(
        null,
        { id: restaurantId },
        mockContext
      );

      expect(result).toBe(true);
      expect(mockPrisma.restaurant.delete).toHaveBeenCalledWith({
        where: { id: restaurantId },
      });
    });

    test('deleteRestaurant: should return false when deletion fails', async () => {
      // Test error handling - like testing exceptions in Python
      const restaurantId = 1;
      mockPrisma.restaurant.delete.mockRejectedValue(new Error('Foreign key constraint'));

      const result = await restaurantResolvers.Mutation.deleteRestaurant(
        null,
        { id: restaurantId },
        mockContext
      );

      expect(result).toBe(false);
    });
  });

  describe('Field Resolvers', () => {
    // Test nested field resolution
    test('Restaurant.invoices: should return invoices for restaurant', async () => {
      const mockInvoices = [{ id: 1, total: 100, restaurantId: 1 }];
      mockPrisma.invoice.findMany.mockResolvedValue(mockInvoices);

      const result = await restaurantResolvers.Restaurant.invoices(
        { id: 1 }, // parent restaurant
        {},
        mockContext
      );

      expect(result).toEqual(mockInvoices);
      expect(mockPrisma.invoice.findMany).toHaveBeenCalledWith({
        where: { restaurantId: 1 },
      });
    });
  });
});
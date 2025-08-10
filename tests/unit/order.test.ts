// Unit tests for order resolvers
// Demonstrates testing of more complex business logic

import { orderResolvers } from '../../src/resolvers/order';
import { PrismaClient } from '@prisma/client';

const mockPrisma = new PrismaClient() as jest.Mocked<PrismaClient>;
const mockContext = { prisma: mockPrisma };

// Test data
const mockOrder = {
  id: 1,
  createdAt: new Date('2024-01-01'),
  tableId: 1,
  invoiceId: null,
  orderItems: [
    {
      id: 1,
      orderId: 1,
      itemId: 1,
      quantity: 2,
      price: 15.99,
      state: 'PENDING',
      item: { id: 1, name: 'Test Item', price: 15.99 }
    }
  ],
  rtable: { id: 1, name: 'Table 1' },
  invoice: null,
};

describe('Order Resolvers', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Query Resolvers', () => {
    test('orders: should return all orders when no tableId provided', async () => {
      // Test querying all orders (like SELECT * FROM orders)
      const mockOrders = [mockOrder];
      (mockPrisma.order.findMany as jest.Mock).mockResolvedValue(mockOrders);

      const result = await orderResolvers.Query.orders(
        null,
        {}, // No tableId filter
        mockContext
      );

      expect(result).toEqual(mockOrders);
      expect(mockPrisma.order.findMany).toHaveBeenCalledWith({
        where: {}, // No filter when tableId not provided
        include: {
          orderItems: {
            include: { item: true },
          },
          rtable: true,
          invoice: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });
    });

    test('orders: should filter by tableId when provided', async () => {
      // Test conditional querying - shows TypeScript optional parameters
      const tableId = 1;
      (mockPrisma.order.findMany as jest.Mock).mockResolvedValue([mockOrder]);

      const result = await orderResolvers.Query.orders(
        null,
        { tableId }, // With tableId filter
        mockContext
      );

      expect(mockPrisma.order.findMany).toHaveBeenCalledWith({
        where: { tableId }, // Filter applied
        include: {
          orderItems: {
            include: { item: true },
          },
          rtable: true,
          invoice: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });
    });

    test('order: should return single order with nested data', async () => {
      // Test deep nesting - shows GraphQL's nested data fetching
      (mockPrisma.order.findUnique as jest.Mock).mockResolvedValue(mockOrder);

      const result = await orderResolvers.Query.order(
        null,
        { id: 1 },
        mockContext
      );

      expect(result).toEqual(mockOrder);
      expect(mockPrisma.order.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
        include: {
          orderItems: {
            include: { item: true },
          },
          rtable: true,
          invoice: true,
        },
      });
    });
  });

  describe('Mutation Resolvers', () => {
    test('createOrder: should create new order for table', async () => {
      // Test order creation
      const input = { tableId: 1 };
      const expectedOrder = {
        id: 2,
        createdAt: new Date(),
        tableId: 1,
        invoiceId: null,
        orderItems: [],
        rtable: { id: 1, name: 'Table 1' },
        invoice: null,
      };

      (mockPrisma.order.create as jest.Mock).mockResolvedValue(expectedOrder);

      const result = await orderResolvers.Mutation.createOrder(
        null,
        { input },
        mockContext
      );

      expect(result).toEqual(expectedOrder);
      expect(mockPrisma.order.create).toHaveBeenCalledWith({
        data: { tableId: 1 },
        include: {
          orderItems: true,
          rtable: true,
          invoice: true,
        },
      });
    });

    test('deleteOrder: should delete order and handle cascade', async () => {
      // Test cascade deletion (orderItems should be deleted automatically)
      (mockPrisma.order.delete as jest.Mock).mockResolvedValue(mockOrder);

      const result = await orderResolvers.Mutation.deleteOrder(
        null,
        { id: 1 },
        mockContext
      );

      expect(result).toBe(true);
      expect(mockPrisma.order.delete).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });

    test('deleteOrder: should handle deletion errors gracefully', async () => {
      // Test error handling with logging
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      (mockPrisma.order.delete as jest.Mock).mockRejectedValue(new Error('Cannot delete'));

      const result = await orderResolvers.Mutation.deleteOrder(
        null,
        { id: 1 },
        mockContext
      );

      expect(result).toBe(false);
      expect(consoleErrorSpy).toHaveBeenCalledWith('Error deleting order:', expect.any(Error));
      
      consoleErrorSpy.mockRestore();
    });
  });

  describe('Field Resolvers', () => {
    test('Order.orderItems: should fetch order items with item details', async () => {
      // Test nested field resolution
      const mockOrderItems = [
        {
          id: 1,
          orderId: 1,
          itemId: 1,
          quantity: 2,
          price: 15.99,
          state: 'PENDING',
          item: { id: 1, name: 'Test Item', price: 15.99 }
        }
      ];

      (mockPrisma.orderItem.findMany as jest.Mock).mockResolvedValue(mockOrderItems);

      const result = await orderResolvers.Order.orderItems(
        { id: 1 }, // parent order
        {},
        mockContext
      );

      expect(result).toEqual(mockOrderItems);
      expect(mockPrisma.orderItem.findMany).toHaveBeenCalledWith({
        where: { orderId: 1 },
        include: { item: true },
      });
    });

    test('Order.invoice: should return null when no invoice', async () => {
      // Test nullable relationship handling
      const result = await orderResolvers.Order.invoice(
        { invoiceId: null }, // No invoice linked
        {},
        mockContext
      );

      expect(result).toBeNull();
      expect(mockPrisma.invoice.findUnique).not.toHaveBeenCalled();
    });

    test('Order.invoice: should fetch invoice when linked', async () => {
      // Test invoice relationship
      const mockInvoice = { id: 1, total: 100 };
      (mockPrisma.invoice.findUnique as jest.Mock).mockResolvedValue(mockInvoice);

      const result = await orderResolvers.Order.invoice(
        { invoiceId: 1 }, // Invoice linked
        {},
        mockContext
      );

      expect(result).toEqual(mockInvoice);
      expect(mockPrisma.invoice.findUnique).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });
  });
});
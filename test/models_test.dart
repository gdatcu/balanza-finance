import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/models/account.dart';
import 'package:balanza/models/category.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/models/category_summary.dart';
import 'package:balanza/models/net_worth_item.dart';

void main() {
  group('Account Model Tests', () {
    final rawAccountJson = {
      'id': 'a1111111-2222-3333-4444-555555555555',
      'name': 'Primary Checking',
      'balance': 1500, // int in JSON should safely parse to double
      'user_id': 'u1111111-2222-3333-4444-555555555555',
      'created_at': '2026-07-21T12:00:00.000Z',
    };

    test('fromJson parses correctly', () {
      final account = Account.fromJson(rawAccountJson);

      expect(account.id, 'a1111111-2222-3333-4444-555555555555');
      expect(account.name, 'Primary Checking');
      expect(account.balance, 1500.0);
      expect(account.userId, 'u1111111-2222-3333-4444-555555555555');
      expect(account.createdAt, DateTime.parse('2026-07-21T12:00:00.000Z'));
    });

    test('toJson returns correct map', () {
      final account = Account(
        id: 'a1111111-2222-3333-4444-555555555555',
        name: 'Primary Checking',
        balance: 1500.0,
        userId: 'u1111111-2222-3333-4444-555555555555',
        createdAt: DateTime.parse('2026-07-21T12:00:00.000Z'),
      );

      final json = account.toJson();

      expect(json['id'], 'a1111111-2222-3333-4444-555555555555');
      expect(json['name'], 'Primary Checking');
      expect(json['balance'], 1500.0);
      expect(json['user_id'], 'u1111111-2222-3333-4444-555555555555');
      expect(json['created_at'], '2026-07-21T12:00:00.000Z');
    });

    test('copyWith copies fields or defaults correctly', () {
      final account = Account(
        id: '1',
        name: 'Savings',
        balance: 100.0,
        userId: 'u1',
        createdAt: DateTime.now(),
      );

      final updated = account.copyWith(name: 'Investments', balance: 250.5);

      expect(updated.id, '1');
      expect(updated.name, 'Investments');
      expect(updated.balance, 250.5);
      expect(updated.userId, 'u1');
      expect(updated.createdAt, account.createdAt);
    });
  });

  group('Category Model Tests', () {
    final rawCategoryJson = {
      'id': 'c1111111-2222-3333-4444-555555555555',
      'name': 'Food & Dining',
      'icon': 'fastfood',
      'color': '#FF5733',
      'user_id': 'u1111111-2222-3333-4444-555555555555',
      'created_at': '2026-07-21T12:05:00.000Z',
    };

    test('fromJson parses correctly', () {
      final category = Category.fromJson(rawCategoryJson);

      expect(category.id, 'c1111111-2222-3333-4444-555555555555');
      expect(category.name, 'Food & Dining');
      expect(category.icon, 'fastfood');
      expect(category.color, '#FF5733');
      expect(category.userId, 'u1111111-2222-3333-4444-555555555555');
      expect(category.createdAt, DateTime.parse('2026-07-21T12:05:00.000Z'));
    });

    test('toJson returns correct map', () {
      final category = Category(
        id: 'c1111111-2222-3333-4444-555555555555',
        name: 'Food & Dining',
        icon: 'fastfood',
        color: '#FF5733',
        userId: 'u1111111-2222-3333-4444-555555555555',
        createdAt: DateTime.parse('2026-07-21T12:05:00.000Z'),
      );

      final json = category.toJson();

      expect(json['id'], 'c1111111-2222-3333-4444-555555555555');
      expect(json['name'], 'Food & Dining');
      expect(json['icon'], 'fastfood');
      expect(json['color'], '#FF5733');
      expect(json['user_id'], 'u1111111-2222-3333-4444-555555555555');
      expect(json['created_at'], '2026-07-21T12:05:00.000Z');
    });

    test('copyWith copies fields or defaults correctly', () {
      final category = Category(
        id: '1',
        name: 'Groceries',
        createdAt: DateTime.now(),
      );

      final updated = category.copyWith(color: '#00FF00');

      expect(updated.id, '1');
      expect(updated.name, 'Groceries');
      expect(updated.color, '#00FF00');
      expect(updated.icon, isNull);
      expect(updated.userId, isNull);
    });
  });

  group('Transaction Model Tests', () {
    final rawTransactionJson = {
      'id': 't1111111-2222-3333-4444-555555555555',
      'user_id': 'u1111111-2222-3333-4444-555555555555',
      'account_id': 'a1111111-2222-3333-4444-555555555555',
      'category_id': 'c1111111-2222-3333-4444-555555555555',
      'amount': -45.50,
      'description': 'Supermarket spend',
      'date': '2026-07-21T12:10:00.000Z',
      'created_at': '2026-07-21T12:10:05.000Z',
    };

    test('fromJson parses correctly', () {
      final transaction = Transaction.fromJson(rawTransactionJson);

      expect(transaction.id, 't1111111-2222-3333-4444-555555555555');
      expect(transaction.userId, 'u1111111-2222-3333-4444-555555555555');
      expect(transaction.accountId, 'a1111111-2222-3333-4444-555555555555');
      expect(transaction.categoryId, 'c1111111-2222-3333-4444-555555555555');
      expect(transaction.amount, -45.50);
      expect(transaction.description, 'Supermarket spend');
      expect(transaction.date, DateTime.parse('2026-07-21T12:10:00.000Z'));
      expect(transaction.createdAt, DateTime.parse('2026-07-21T12:10:05.000Z'));
    });

    test('toJson returns correct map', () {
      final transaction = Transaction(
        id: 't1111111-2222-3333-4444-555555555555',
        userId: 'u1111111-2222-3333-4444-555555555555',
        accountId: 'a1111111-2222-3333-4444-555555555555',
        categoryId: 'c1111111-2222-3333-4444-555555555555',
        amount: -45.50,
        description: 'Supermarket spend',
        date: DateTime.parse('2026-07-21T12:10:00.000Z'),
        createdAt: DateTime.parse('2026-07-21T12:10:05.000Z'),
      );

      final json = transaction.toJson();

      expect(json['id'], 't1111111-2222-3333-4444-555555555555');
      expect(json['user_id'], 'u1111111-2222-3333-4444-555555555555');
      expect(json['account_id'], 'a1111111-2222-3333-4444-555555555555');
      expect(json['category_id'], 'c1111111-2222-3333-4444-555555555555');
      expect(json['amount'], -45.50);
      expect(json['description'], 'Supermarket spend');
      expect(json['date'], '2026-07-21T12:10:00.000Z');
      expect(json['created_at'], '2026-07-21T12:10:05.000Z');
    });

    test('copyWith copies fields or defaults correctly', () {
      final transaction = Transaction(
        id: '1',
        userId: 'u1',
        accountId: 'a1',
        amount: 200.0,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final updated = transaction.copyWith(amount: 150.0, description: 'Updated Spend');

      expect(updated.id, '1');
      expect(updated.userId, 'u1');
      expect(updated.accountId, 'a1');
      expect(updated.amount, 150.0);
      expect(updated.description, 'Updated Spend');
    });
  });

  group('CategorySummary Model Tests', () {
    test('initializes correctly with values', () {
      const summary = CategorySummary(
        categoryName: 'Food',
        totalAmount: -150.0,
        transactionType: TransactionType.expense,
      );

      expect(summary.categoryName, 'Food');
      expect(summary.totalAmount, -150.0);
      expect(summary.transactionType, TransactionType.expense);
    });
  });

  group('NetWorthItem Model Tests', () {
    test('initializes correctly with values', () {
      final item = NetWorthItem(
        id: 'nw-1',
        userId: 'u-1',
        name: 'House',
        balance: 250000.0,
        type: NetWorthType.asset,
        createdAt: DateTime.parse('2026-07-22T10:00:00Z'),
      );

      expect(item.id, 'nw-1');
      expect(item.userId, 'u-1');
      expect(item.name, 'House');
      expect(item.balance, 250000.0);
      expect(item.type, NetWorthType.asset);
      expect(item.createdAt, DateTime.parse('2026-07-22T10:00:00Z'));
    });

    test('fromJson and toJson map correctly', () {
      final json = {
        'id': 'nw-2',
        'user_id': 'u-2',
        'name': 'Car Loan',
        'balance': 15000.0,
        'type': 'liability',
        'created_at': '2026-07-22T11:00:00.000Z',
      };

      final item = NetWorthItem.fromJson(json);
      expect(item.name, 'Car Loan');
      expect(item.type, NetWorthType.liability);
      expect(item.balance, 15000.0);

      final outJson = item.toJson();
      expect(outJson['id'], 'nw-2');
      expect(outJson['type'], 'liability');
    });
  });
}

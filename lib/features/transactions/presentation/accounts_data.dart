import '../../../models/account.dart';

final List<Account> defaultAccounts = [
  Account(
    id: '00000000-0000-0000-0000-000000000001',
    name: 'Main Checking',
    balance: 2500.0,
    userId: '00000000-0000-0000-0000-000000000000',
    createdAt: DateTime.now(),
  ),
  Account(
    id: '00000000-0000-0000-0000-000000000002',
    name: 'Savings Account',
    balance: 10000.0,
    userId: '00000000-0000-0000-0000-000000000000',
    createdAt: DateTime.now(),
  ),
  Account(
    id: '00000000-0000-0000-0000-000000000003',
    name: 'Credit Card',
    balance: -450.0,
    userId: '00000000-0000-0000-0000-000000000000',
    createdAt: DateTime.now(),
  ),
];

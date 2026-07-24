import 'package:flutter/material.dart';
import '../../../models/category.dart';

final List<Category> defaultCategories = [
  Category(
    id: '00000000-0000-0000-0000-0000000000c1',
    name: 'Food',
    icon: 'lunch_dining',
    color: '#FF9800',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c2',
    name: 'Transport',
    icon: 'directions_car',
    color: '#2196F3',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c3',
    name: 'Rent',
    icon: 'home',
    color: '#9C27B0',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c4',
    name: 'Utilities',
    icon: 'power',
    color: '#E91E63',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c5',
    name: 'Salary',
    icon: 'attach_money',
    color: '#4CAF50',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c6',
    name: 'Entertainment',
    icon: 'sports_esports',
    color: '#FF5722',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c7',
    name: 'Shopping',
    icon: 'shopping_bag',
    color: '#00BCD4',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c8',
    name: 'Investments',
    icon: 'trending_up',
    color: '#3F51B5',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c9',
    name: 'Gifts',
    icon: 'card_giftcard',
    color: '#FFC107',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c10',
    name: 'coffee_tea',
    icon: 'local_cafe',
    color: '#795548',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c11',
    name: 'restaurants',
    icon: 'restaurant',
    color: '#FF5722',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c12',
    name: 'pet_care',
    icon: 'pets',
    color: '#8BC34A',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c13',
    name: 'subscriptions',
    icon: 'subscriptions',
    color: '#9C27B0',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c14',
    name: 'other',
    icon: 'inventory_2',
    color: '#607D8B',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c15',
    name: 'credit_installments',
    icon: 'account_balance',
    color: '#D32F2F',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c16',
    name: 'groceries',
    icon: 'shopping_cart',
    color: '#4CAF50',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c17',
    name: 'meal_tickets',
    icon: 'confirmation_number',
    color: '#8BC34A',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c18',
    name: 'side_hustle',
    icon: 'rocket_launch',
    color: '#00ACC1',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c19',
    name: 'clothing',
    icon: 'checkroom',
    color: '#EC4899',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c20',
    name: 'healthcare',
    icon: 'medical_services',
    color: '#EF4444',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c21',
    name: 'gadgets',
    icon: 'devices',
    color: '#3B82F6',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c22',
    name: 'travel',
    icon: 'flight_takeoff',
    color: '#06B6D4',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c23',
    name: 'entertainment',
    icon: 'theater_comedy',
    color: '#8B5CF6',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c24',
    name: 'transport',
    icon: 'directions_car',
    color: '#F59E0B',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c25',
    name: 'personal_care',
    icon: 'spa',
    color: '#14B8A6',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c26',
    name: 'education',
    icon: 'school',
    color: '#6366F1',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
];

final List<Category> expenseCategories =
    defaultCategories.where((c) => !c.isIncome).toList();

final List<Category> incomeCategories =
    defaultCategories.where((c) => c.isIncome).toList();

IconData getCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'lunch_dining':
      return Icons.lunch_dining;
    case 'directions_car':
    case 'transport':
      return Icons.directions_car;
    case 'home':
      return Icons.home;
    case 'power':
    case 'lightbulb':
      return Icons.lightbulb;
    case 'attach_money':
    case 'payments':
    case 'salary':
      return Icons.payments;
    case 'sports_esports':
    case 'theater_comedy':
    case 'entertainment':
      return Icons.sports_esports;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'trending_up':
      return Icons.trending_up;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'local_cafe':
    case 'coffee':
    case 'coffee_tea':
      return Icons.local_cafe;
    case 'restaurant':
    case 'restaurants':
      return Icons.restaurant;
    case 'pets':
    case 'pet_care':
      return Icons.pets;
    case 'subscriptions':
    case 'repeat':
      return Icons.subscriptions;
    case 'inventory_2':
    case 'category':
    case 'other':
      return Icons.inventory_2;
    case 'account_balance':
    case 'credit_installments':
    case 'credit':
      return Icons.account_balance;
    case 'shopping_cart':
    case 'groceries':
      return Icons.shopping_cart;
    case 'confirmation_number':
    case 'meal_tickets':
      return Icons.confirmation_number;
    case 'rocket_launch':
    case 'side_hustle':
      return Icons.rocket_launch;
    case 'checkroom':
    case 'clothing':
      return Icons.checkroom;
    case 'medical_services':
    case 'healthcare':
      return Icons.medical_services;
    case 'devices':
    case 'gadgets':
      return Icons.devices;
    case 'flight_takeoff':
    case 'travel':
      return Icons.flight_takeoff;
    case 'spa':
    case 'personal_care':
      return Icons.spa;
    case 'school':
    case 'education':
      return Icons.school;
    default:
      return Icons.category;
  }
}

Color getCategoryColor(String? hexString) {
  if (hexString == null) return Colors.grey;
  final hex = hexString.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

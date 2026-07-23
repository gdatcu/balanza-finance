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
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000000c9',
    name: 'Gifts',
    icon: 'card_giftcard',
    color: '#FFC107',
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
];

final List<Category> expenseCategories = defaultCategories.where((c) =>
    c.id == '00000000-0000-0000-0000-0000000000c1' ||
    c.id == '00000000-0000-0000-0000-0000000000c2' ||
    c.id == '00000000-0000-0000-0000-0000000000c3' ||
    c.id == '00000000-0000-0000-0000-0000000000c4' ||
    c.id == '00000000-0000-0000-0000-0000000000c6' ||
    c.id == '00000000-0000-0000-0000-0000000000c7' ||
    c.id == '00000000-0000-0000-0000-000000000c10' ||
    c.id == '00000000-0000-0000-0000-000000000c11' ||
    c.id == '00000000-0000-0000-0000-000000000c12' ||
    c.id == '00000000-0000-0000-0000-000000000c13' ||
    c.id == '00000000-0000-0000-0000-000000000c14').toList();

final List<Category> incomeCategories = defaultCategories.where((c) =>
    c.id == '00000000-0000-0000-0000-0000000000c5' ||
    c.id == '00000000-0000-0000-0000-0000000000c8' ||
    c.id == '00000000-0000-0000-0000-0000000000c9').toList();

IconData getCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'lunch_dining':
      return Icons.lunch_dining;
    case 'directions_car':
      return Icons.directions_car;
    case 'home':
      return Icons.home;
    case 'power':
      return Icons.power;
    case 'attach_money':
      return Icons.attach_money;
    case 'sports_esports':
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
    default:
      return Icons.category;
  }
}

Color getCategoryColor(String? hexString) {
  if (hexString == null) return Colors.grey;
  final hex = hexString.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

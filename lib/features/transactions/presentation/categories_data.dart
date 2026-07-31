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
    id: '00000000-0000-0000-0000-000000000c20',
    name: 'healthcare',
    icon: 'medical_services',
    color: '#EF4444',
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

  // --- Subcategories ---
  // Food
  Category(
    id: '00000000-0000-0000-0000-000000000c10',
    name: 'coffee_tea',
    icon: 'local_cafe',
    color: '#795548',
    parentId: '00000000-0000-0000-0000-0000000000c1',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c11',
    name: 'restaurants',
    icon: 'restaurant',
    color: '#FF5722',
    parentId: '00000000-0000-0000-0000-0000000000c1',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c16',
    name: 'groceries',
    icon: 'shopping_cart',
    color: '#4CAF50',
    isIncome: false,
    parentId: '00000000-0000-0000-0000-0000000000c1',
    createdAt: DateTime.now(),
  ),

  // Transport
  Category(
    id: '00000000-0000-0000-0000-00000000c24a',
    name: 'rideshare_taxi',
    icon: 'local_taxi',
    color: '#F59E0B',
    parentId: '00000000-0000-0000-0000-0000000000c2',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c24b',
    name: 'fuel_gas',
    icon: 'local_gas_station',
    color: '#EF4444',
    parentId: '00000000-0000-0000-0000-0000000000c2',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c24c',
    name: 'public_transit',
    icon: 'directions_bus',
    color: '#3B82F6',
    parentId: '00000000-0000-0000-0000-0000000000c2',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c24d',
    name: 'car_maintenance',
    icon: 'build',
    color: '#64748B',
    parentId: '00000000-0000-0000-0000-0000000000c2',
    createdAt: DateTime.now(),
  ),

  // Rent / Housing
  Category(
    id: '00000000-0000-0000-0000-00000000c30a',
    name: 'rent_payment',
    icon: 'key',
    color: '#9C27B0',
    parentId: '00000000-0000-0000-0000-0000000000c3',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c30b',
    name: 'housing_maintenance',
    icon: 'foundation',
    color: '#AB47BC',
    parentId: '00000000-0000-0000-0000-0000000000c3',
    createdAt: DateTime.now(),
  ),

  // Utilities
  Category(
    id: '00000000-0000-0000-0000-000000000c4a',
    name: 'electricity',
    icon: 'flash_on',
    color: '#F59E0B',
    parentId: '00000000-0000-0000-0000-0000000000c4',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c4b',
    name: 'internet_tv',
    icon: 'wifi',
    color: '#3B82F6',
    parentId: '00000000-0000-0000-0000-0000000000c4',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c4c',
    name: 'water_gas',
    icon: 'water_drop',
    color: '#06B6D4',
    parentId: '00000000-0000-0000-0000-0000000000c4',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c4d',
    name: 'mobile_phone',
    icon: 'phone_android',
    color: '#10B981',
    parentId: '00000000-0000-0000-0000-0000000000c4',
    createdAt: DateTime.now(),
  ),

  // Salary
  Category(
    id: '00000000-0000-0000-0000-00000000c50a',
    name: 'main_salary',
    icon: 'payments',
    color: '#4CAF50',
    parentId: '00000000-0000-0000-0000-0000000000c5',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c17',
    name: 'meal_tickets',
    icon: 'confirmation_number',
    color: '#8BC34A',
    parentId: '00000000-0000-0000-0000-0000000000c5',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c18',
    name: 'side_hustle',
    icon: 'rocket_launch',
    color: '#00ACC1',
    parentId: '00000000-0000-0000-0000-0000000000c5',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c50b',
    name: 'bonus',
    icon: 'military_tech',
    color: '#81C784',
    parentId: '00000000-0000-0000-0000-0000000000c5',
    isIncome: true,
    createdAt: DateTime.now(),
  ),

  // Entertainment
  Category(
    id: '00000000-0000-0000-0000-000000000c13',
    name: 'subscriptions',
    icon: 'subscriptions',
    color: '#9C27B0',
    parentId: '00000000-0000-0000-0000-0000000000c6',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c60a',
    name: 'events_outings',
    icon: 'movie',
    color: '#FF7043',
    parentId: '00000000-0000-0000-0000-0000000000c6',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c60b',
    name: 'hobbies_sports',
    icon: 'sports_soccer',
    color: '#FF8A65',
    parentId: '00000000-0000-0000-0000-0000000000c6',
    createdAt: DateTime.now(),
  ),

  // Shopping
  Category(
    id: '00000000-0000-0000-0000-000000000c19',
    name: 'clothing',
    icon: 'checkroom',
    color: '#EC4899',
    parentId: '00000000-0000-0000-0000-0000000000c7',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-000000000c21',
    name: 'gadgets',
    icon: 'devices',
    color: '#3B82F6',
    parentId: '00000000-0000-0000-0000-0000000000c7',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c70a',
    name: 'home_living',
    icon: 'chair',
    color: '#26C6DA',
    parentId: '00000000-0000-0000-0000-0000000000c7',
    isIncome: false,
    createdAt: DateTime.now(),
  ),

  // Investments
  Category(
    id: '00000000-0000-0000-0000-00000000c80a',
    name: 'stocks_etfs',
    icon: 'show_chart',
    color: '#3F51B5',
    parentId: '00000000-0000-0000-0000-0000000000c8',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c80b',
    name: 'crypto',
    icon: 'currency_bitcoin',
    color: '#5C6BC0',
    parentId: '00000000-0000-0000-0000-0000000000c8',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c80c',
    name: 'real_estate',
    icon: 'location_city',
    color: '#7986CB',
    parentId: '00000000-0000-0000-0000-0000000000c8',
    isIncome: true,
    createdAt: DateTime.now(),
  ),

  // Gifts
  Category(
    id: '00000000-0000-0000-0000-00000000c90a',
    name: 'gift_received',
    icon: 'card_giftcard',
    color: '#FFC107',
    parentId: '00000000-0000-0000-0000-0000000000c9',
    isIncome: true,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c90b',
    name: 'gift_given',
    icon: 'volunteer_activism',
    color: '#FFD54F',
    parentId: '00000000-0000-0000-0000-0000000000c9',
    isIncome: false,
    createdAt: DateTime.now(),
  ),

  // Healthcare
  Category(
    id: '00000000-0000-0000-0000-00000000c20a',
    name: 'pharmacy',
    icon: 'medication',
    color: '#EF4444',
    parentId: '00000000-0000-0000-0000-000000000c20',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-00000000c20b',
    name: 'doctor_clinic',
    icon: 'local_hospital',
    color: '#10B981',
    parentId: '00000000-0000-0000-0000-000000000c20',
    isIncome: false,
    createdAt: DateTime.now(),
  ),

  // Travel
  Category(
    id: '00000000-0000-0000-0000-0000000c220a',
    name: 'flights_transit',
    icon: 'flight',
    color: '#06B6D4',
    parentId: '00000000-0000-0000-0000-000000000c22',
    isIncome: false,
    createdAt: DateTime.now(),
  ),
  Category(
    id: '00000000-0000-0000-0000-0000000c220b',
    name: 'hotels_stay',
    icon: 'hotel',
    color: '#22D3EE',
    parentId: '00000000-0000-0000-0000-000000000c22',
    isIncome: false,
    createdAt: DateTime.now(),
  ),

  // Personal Care
  Category(
    id: '00000000-0000-0000-0000-0000000c250a',
    name: 'barber_salon',
    icon: 'content_cut',
    color: '#14B8A6',
    parentId: '00000000-0000-0000-0000-000000000c25',
    isIncome: false,
    createdAt: DateTime.now(),
  ),

  // Education
  Category(
    id: '00000000-0000-0000-0000-0000000c260a',
    name: 'courses_books',
    icon: 'menu_book',
    color: '#6366F1',
    parentId: '00000000-0000-0000-0000-000000000c26',
    isIncome: false,
    createdAt: DateTime.now(),
  ),

  // Other / Standalone
  Category(
    id: '00000000-0000-0000-0000-000000000c12',
    name: 'pet_care',
    icon: 'pets',
    color: '#8BC34A',
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
    case 'local_taxi':
    case 'rideshare_taxi':
      return Icons.local_taxi;
    case 'local_gas_station':
    case 'fuel_gas':
      return Icons.local_gas_station;
    case 'directions_bus':
    case 'public_transit':
      return Icons.directions_bus;
    case 'build':
    case 'car_maintenance':
      return Icons.build;
    case 'home':
      return Icons.home;
    case 'power':
    case 'lightbulb':
      return Icons.lightbulb;
    case 'flash_on':
    case 'electricity':
      return Icons.flash_on;
    case 'wifi':
    case 'internet_tv':
      return Icons.wifi;
    case 'water_drop':
    case 'water_gas':
      return Icons.water_drop;
    case 'phone_android':
    case 'mobile_phone':
    case 'phone':
      return Icons.phone_android;
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
    case 'medication':
    case 'pharmacy':
      return Icons.medication;
    case 'local_hospital':
    case 'doctor_clinic':
      return Icons.local_hospital;
    case 'devices':
    case 'gadgets':
      return Icons.devices;
    case 'flight_takeoff':
    case 'travel':
      return Icons.flight_takeoff;
    case 'key':
    case 'rent_payment':
      return Icons.key;
    case 'foundation':
    case 'housing_maintenance':
      return Icons.foundation;
    case 'movie':
    case 'events_outings':
      return Icons.movie;
    case 'sports_soccer':
    case 'hobbies_sports':
      return Icons.sports_soccer;
    case 'chair':
    case 'home_living':
      return Icons.chair;
    case 'show_chart':
    case 'stocks_etfs':
      return Icons.show_chart;
    case 'currency_bitcoin':
    case 'crypto':
      return Icons.currency_bitcoin;
    case 'location_city':
    case 'real_estate':
      return Icons.location_city;
    case 'volunteer_activism':
    case 'gift_given':
      return Icons.volunteer_activism;
    case 'military_tech':
    case 'bonus':
      return Icons.military_tech;
    case 'flight':
    case 'flights_transit':
      return Icons.flight;
    case 'hotel':
    case 'hotels_stay':
      return Icons.hotel;
    case 'content_cut':
    case 'barber_salon':
      return Icons.content_cut;
    case 'menu_book':
    case 'courses_books':
      return Icons.menu_book;
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

import '../../models/tagging_rule.dart';

final List<TaggingRule> defaultTaggingRules = [
  // Groceries (Food -> groceries '00000000-0000-0000-0000-000000000c16')
  const TaggingRule(id: 'rule-kaufland', keyword: 'kaufland', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-lidl', keyword: 'lidl', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-carrefour', keyword: 'carrefour', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-mega', keyword: 'mega image', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-froo', keyword: 'froo', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-profi', keyword: 'profi', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-auchan', keyword: 'auchan', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-penny', keyword: 'penny', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),

  // Coffee & Tea (Food -> coffee_tea '00000000-0000-0000-0000-000000000c10')
  const TaggingRule(id: 'rule-starbucks', keyword: 'starbucks', category: 'Food', subCategory: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-5togo', keyword: '5togo', category: 'Food', subCategory: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-5togo2', keyword: '5 to go', category: 'Food', subCategory: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-tucano', keyword: 'tucano', category: 'Food', subCategory: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-mccafe', keyword: 'mccafe', category: 'Food', subCategory: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),

  // Restaurants & Fast Food (Food -> restaurants '00000000-0000-0000-0000-000000000c11')
  const TaggingRule(id: 'rule-mcdonalds', keyword: 'mcdonald', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-kfc', keyword: 'kfc', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-glovo', keyword: 'glovo', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-tazz', keyword: 'tazz', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-wolt', keyword: 'wolt', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),

  // Transport -> Rideshare & Taxi ('00000000-0000-0000-0000-00000000c24a')
  const TaggingRule(id: 'rule-uber', keyword: 'uber', category: 'Transport', subCategory: 'rideshare_taxi', categoryId: '00000000-0000-0000-0000-00000000c24a'),
  const TaggingRule(id: 'rule-bolt', keyword: 'bolt', category: 'Transport', subCategory: 'rideshare_taxi', categoryId: '00000000-0000-0000-0000-00000000c24a'),

  // Transport -> Fuel & Gas ('00000000-0000-0000-0000-00000000c24b')
  const TaggingRule(id: 'rule-omv', keyword: 'omv', category: 'Transport', subCategory: 'fuel_gas', categoryId: '00000000-0000-0000-0000-00000000c24b'),
  const TaggingRule(id: 'rule-petrom', keyword: 'petrom', category: 'Transport', subCategory: 'fuel_gas', categoryId: '00000000-0000-0000-0000-00000000c24b'),
  const TaggingRule(id: 'rule-rompetrol', keyword: 'rompetrol', category: 'Transport', subCategory: 'fuel_gas', categoryId: '00000000-0000-0000-0000-00000000c24b'),
  const TaggingRule(id: 'rule-lukoil', keyword: 'lukoil', category: 'Transport', subCategory: 'fuel_gas', categoryId: '00000000-0000-0000-0000-00000000c24b'),
  const TaggingRule(id: 'rule-mol', keyword: 'mol', category: 'Transport', subCategory: 'fuel_gas', categoryId: '00000000-0000-0000-0000-00000000c24b'),

  // Subscriptions (Entertainment -> subscriptions '00000000-0000-0000-0000-000000000c13')
  const TaggingRule(id: 'rule-netflix', keyword: 'netflix', category: 'Entertainment', subCategory: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13'),
  const TaggingRule(id: 'rule-spotify', keyword: 'spotify', category: 'Entertainment', subCategory: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13'),
  const TaggingRule(id: 'rule-youtube', keyword: 'youtube', category: 'Entertainment', subCategory: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13'),

  // Shopping -> Gadgets & Tech ('00000000-0000-0000-0000-000000000c21')
  const TaggingRule(id: 'rule-emag', keyword: 'emag', category: 'Shopping', subCategory: 'gadgets', categoryId: '00000000-0000-0000-0000-000000000c21'),
  const TaggingRule(id: 'rule-altex', keyword: 'altex', category: 'Shopping', subCategory: 'gadgets', categoryId: '00000000-0000-0000-0000-000000000c21'),
  const TaggingRule(id: 'rule-flanco', keyword: 'flanco', category: 'Shopping', subCategory: 'gadgets', categoryId: '00000000-0000-0000-0000-000000000c21'),

  // Shopping -> Clothing & Fashion ('00000000-0000-0000-0000-000000000c19')
  const TaggingRule(id: 'rule-zara', keyword: 'zara', category: 'Shopping', subCategory: 'clothing', categoryId: '00000000-0000-0000-0000-000000000c19'),
  const TaggingRule(id: 'rule-hm', keyword: 'h&m', category: 'Shopping', subCategory: 'clothing', categoryId: '00000000-0000-0000-0000-000000000c19'),
  const TaggingRule(id: 'rule-fashiondays', keyword: 'fashion days', category: 'Shopping', subCategory: 'clothing', categoryId: '00000000-0000-0000-0000-000000000c19'),
  const TaggingRule(id: 'rule-fashiondays2', keyword: 'fashiondays', category: 'Shopping', subCategory: 'clothing', categoryId: '00000000-0000-0000-0000-000000000c19'),
  const TaggingRule(id: 'rule-ccc', keyword: 'ccc', category: 'Shopping', subCategory: 'clothing', categoryId: '00000000-0000-0000-0000-000000000c19'),

  // Restaurants (Food -> restaurants '00000000-0000-0000-0000-000000000c11')
  const TaggingRule(id: 'rule-oceanulindian', keyword: 'oceanul indian', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-cevabun', keyword: 'ceva bun', category: 'Food', subCategory: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),

  // Coffee & Tea (Food -> coffee_tea '00000000-0000-0000-0000-000000000c10')
  const TaggingRule(id: 'rule-goldencoffe', keyword: 'golden coffe', category: 'Food', subCategory: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),

  // Groceries (Food -> groceries '00000000-0000-0000-0000-000000000c16')
  const TaggingRule(id: 'rule-dingradini', keyword: 'dingradini', category: 'Food', subCategory: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),

  // Utilities -> Electricity ('00000000-0000-0000-0000-000000000c14')
  const TaggingRule(id: 'rule-ppc', keyword: 'ppc energie', category: 'Utilities', subCategory: 'electricity', categoryId: '00000000-0000-0000-0000-000000000c14'),

  // Pets / Medical / Vet -> Pharmacy or Other
  const TaggingRule(id: 'rule-tjpetshop', keyword: 'tj pet shop', category: 'healthcare', subCategory: 'pharmacy', categoryId: '00000000-0000-0000-0000-00000000c20a'),
  const TaggingRule(id: 'rule-tjvet', keyword: 'tj vet', category: 'healthcare', subCategory: 'pharmacy', categoryId: '00000000-0000-0000-0000-00000000c20a'),

  // Health & Medical -> Pharmacy ('00000000-0000-0000-0000-00000000c20a')
  const TaggingRule(id: 'rule-catena', keyword: 'catena', category: 'healthcare', subCategory: 'pharmacy', categoryId: '00000000-0000-0000-0000-00000000c20a'),
  const TaggingRule(id: 'rule-drmax', keyword: 'dr.max', category: 'healthcare', subCategory: 'pharmacy', categoryId: '00000000-0000-0000-0000-00000000c20a'),
  const TaggingRule(id: 'rule-helpnet', keyword: 'help net', category: 'healthcare', subCategory: 'pharmacy', categoryId: '00000000-0000-0000-0000-00000000c20a'),
  const TaggingRule(id: 'rule-sensiblu', keyword: 'sensiblu', category: 'healthcare', subCategory: 'pharmacy', categoryId: '00000000-0000-0000-0000-00000000c20a'),
  // Utilities -> Mobile & Phone ('00000000-0000-0000-0000-000000000c4d')
  const TaggingRule(id: 'rule-orange', keyword: 'orange', category: 'Utilities', subCategory: 'mobile_phone', categoryId: '00000000-0000-0000-0000-000000000c4d'),
  const TaggingRule(id: 'rule-vodafone', keyword: 'vodafone', category: 'Utilities', subCategory: 'mobile_phone', categoryId: '00000000-0000-0000-0000-000000000c4d'),
  const TaggingRule(id: 'rule-telekom', keyword: 'telekom', category: 'Utilities', subCategory: 'mobile_phone', categoryId: '00000000-0000-0000-0000-000000000c4d'),
  const TaggingRule(id: 'rule-digi', keyword: 'digi', category: 'Utilities', subCategory: 'mobile_phone', categoryId: '00000000-0000-0000-0000-000000000c4d'),
  const TaggingRule(id: 'rule-rcs', keyword: 'rcs', category: 'Utilities', subCategory: 'mobile_phone', categoryId: '00000000-0000-0000-0000-000000000c4d'),
  const TaggingRule(id: 'rule-yoxo', keyword: 'yoxo', category: 'Utilities', subCategory: 'mobile_phone', categoryId: '00000000-0000-0000-0000-000000000c4d'),
];

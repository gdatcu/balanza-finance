import '../../models/tagging_rule.dart';

final List<TaggingRule> defaultTaggingRules = [
  // Groceries ('00000000-0000-0000-0000-000000000c16')
  const TaggingRule(id: 'rule-kaufland', keyword: 'kaufland', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-lidl', keyword: 'lidl', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-carrefour', keyword: 'carrefour', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-mega', keyword: 'mega image', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-profi', keyword: 'profi', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-auchan', keyword: 'auchan', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),
  const TaggingRule(id: 'rule-penny', keyword: 'penny', category: 'groceries', categoryId: '00000000-0000-0000-0000-000000000c16'),

  // Coffee & Tea ('00000000-0000-0000-0000-000000000c10')
  const TaggingRule(id: 'rule-starbucks', keyword: 'starbucks', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-5togo', keyword: '5togo', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-5togo2', keyword: '5 to go', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-tucano', keyword: 'tucano', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),
  const TaggingRule(id: 'rule-mccafe', keyword: 'mccafe', category: 'coffee_tea', categoryId: '00000000-0000-0000-0000-000000000c10'),

  // Restaurants & Fast Food ('00000000-0000-0000-0000-000000000c11')
  const TaggingRule(id: 'rule-mcdonalds', keyword: 'mcdonald', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-kfc', keyword: 'kfc', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-glovo', keyword: 'glovo', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-tazz', keyword: 'tazz', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),
  const TaggingRule(id: 'rule-wolt', keyword: 'wolt', category: 'restaurants', categoryId: '00000000-0000-0000-0000-000000000c11'),

  // Transport ('00000000-0000-0000-0000-0000000000c2')
  const TaggingRule(id: 'rule-uber', keyword: 'uber', category: 'Transport', categoryId: '00000000-0000-0000-0000-0000000000c2'),
  const TaggingRule(id: 'rule-bolt', keyword: 'bolt', category: 'Transport', categoryId: '00000000-0000-0000-0000-0000000000c2'),
  const TaggingRule(id: 'rule-omv', keyword: 'omv', category: 'Transport', categoryId: '00000000-0000-0000-0000-0000000000c2'),
  const TaggingRule(id: 'rule-petrom', keyword: 'petrom', category: 'Transport', categoryId: '00000000-0000-0000-0000-0000000000c2'),

  // Subscriptions ('00000000-0000-0000-0000-000000000c13')
  const TaggingRule(id: 'rule-netflix', keyword: 'netflix', category: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13'),
  const TaggingRule(id: 'rule-spotify', keyword: 'spotify', category: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13'),
  const TaggingRule(id: 'rule-youtube', keyword: 'youtube', category: 'subscriptions', categoryId: '00000000-0000-0000-0000-000000000c13'),

  // Shopping ('00000000-0000-0000-0000-0000000000c7')
  const TaggingRule(id: 'rule-emag', keyword: 'emag', category: 'Shopping', categoryId: '00000000-0000-0000-0000-0000000000c7'),
  const TaggingRule(id: 'rule-zara', keyword: 'zara', category: 'Shopping', categoryId: '00000000-0000-0000-0000-0000000000c7'),
  const TaggingRule(id: 'rule-hm', keyword: 'h&m', category: 'Shopping', categoryId: '00000000-0000-0000-0000-0000000000c7'),
];

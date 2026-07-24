# Balanza Finance v1.8.0 Release Notes

## ⚡ New Features

### 🏷️ Enhanced Priority-Based Auto-Tagging & Category Matching Engine
- Upgraded `TaggingRule` data model with `priority` field support (`default: 5`, high priority: `10`).
- Updated `TransactionParser` to evaluate active rules by **priority descending** first, then **keyword length descending**, ensuring specific bank installments (`priority: 10`) and exact store rules take precedence over general keywords.
- Created `CategoryMatcher` to automatically resolve legacy rule category names (`Food`, `Income`, `Health`, `Entertainment`), subcategories (`Coffee`, `Groceries`, `Delivery`, `Pharmacy`, `Freelance`), and tags into exact Balanza category models.
- Integrated automatic Income vs. Expense toggle (`_isIncome`) switching when typing keywords into notes so category dropdown selections remain 100% valid and reactive.

### 🗄️ Database Tagging Rules Standardization Script
- Created SQL migration script `update_tagging_rules_for_expanded_categories.sql` to standardize all 98 tagging rules in Supabase DB to point directly to Balanza category keys (`coffee_tea`, `groceries`, `restaurants`, `credit_installments`, `meal_tickets`, `salary`, `side_hustle`, `pet_care`, `subscriptions`, `utilities`, `transport`, `rent`, `shopping`, `food`, `investments`, `gifts`, `other`).

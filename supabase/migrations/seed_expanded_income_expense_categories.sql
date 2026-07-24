-- Migration: Seed expanded income and expense categories (credit_installments, groceries, meal_tickets, side_hustle)
INSERT INTO categories (id, name, icon, color, is_income, created_at)
VALUES 
  ('00000000-0000-0000-0000-000000000c15', 'credit_installments', 'account_balance', '#D32F2F', false, NOW()),
  ('00000000-0000-0000-0000-000000000c16', 'groceries', 'shopping_cart', '#4CAF50', false, NOW()),
  ('00000000-0000-0000-0000-000000000c17', 'meal_tickets', 'confirmation_number', '#8BC34A', true, NOW()),
  ('00000000-0000-0000-0000-000000000c18', 'side_hustle', 'rocket_launch', '#00ACC1', true, NOW())
ON CONFLICT (id) DO NOTHING;

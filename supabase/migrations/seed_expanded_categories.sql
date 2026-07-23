-- Migration: Seed expanded spending categories (coffee_tea, restaurants, pet_care, subscriptions, other)
INSERT INTO categories (id, name, icon, color, created_at)
VALUES 
  ('00000000-0000-0000-0000-000000000c10', 'coffee_tea', 'local_cafe', '#795548', NOW()),
  ('00000000-0000-0000-0000-000000000c11', 'restaurants', 'restaurant', '#FF5722', NOW()),
  ('00000000-0000-0000-0000-000000000c12', 'pet_care', 'pets', '#8BC34A', NOW()),
  ('00000000-0000-0000-0000-000000000c13', 'subscriptions', 'subscriptions', '#9C27B0', NOW()),
  ('00000000-0000-0000-0000-000000000c14', 'other', 'inventory_2', '#607D8B', NOW())
ON CONFLICT (id) DO NOTHING;

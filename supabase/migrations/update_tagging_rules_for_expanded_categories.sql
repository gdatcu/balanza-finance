-- Migration: Update existing tagging rules to align with expanded Balanza category names
-- Run this script in your Supabase SQL Editor to standardize all 98 tagging rules in the database.

UPDATE tagging_rules SET category = 'coffee_tea', priority = 10 WHERE keyword IN ('5togo', '5 to go', 'starbucks', 'meron', 'ted''s coffee', 'costa coffee');
UPDATE tagging_rules SET category = 'coffee_tea', priority = 5 WHERE keyword = 'coffee';

UPDATE tagging_rules SET category = 'groceries', priority = 5 WHERE keyword IN ('lidl', 'penny', 'mega image', 'selgros', 'supermarket', 'profi', 'metro');

UPDATE tagging_rules SET category = 'restaurants', priority = 5 WHERE keyword IN ('bolt food', 'mcdonalds', 'burger king', 'trattoria', 'restaurant', 'bistro');

UPDATE tagging_rules SET category = 'credit_installments', priority = 10 WHERE keyword IN (
  'banca transilvania rata', 'credit revolut', 'salt rata', 'bcr rata', 
  'raiffeisen credit', 'rata raiffeisen', 'salt credit', 'revolut rata', 
  'rata salt', 'rata revolut', 'credit raiffeisen', 'credit salt', 
  'unicredit rata', 'ing bank rata', 'rata bcr'
);
UPDATE tagging_rules SET category = 'credit_installments', priority = 5 WHERE keyword = 'credit';

UPDATE tagging_rules SET category = 'meal_tickets', priority = 10 WHERE keyword IN ('tichete', 'edenred', 'pluxee');

UPDATE tagging_rules SET category = 'salary', priority = 10 WHERE keyword IN ('avans salariu', 'lichidare', 'paycheck', 'salary', 'salariu');

UPDATE tagging_rules SET category = 'side_hustle', priority = 5 WHERE keyword IN ('upwork', 'plata factura');

UPDATE tagging_rules SET category = 'investments', priority = 5 WHERE keyword = 'dividende';

UPDATE tagging_rules SET category = 'subscriptions', priority = 5 WHERE keyword IN ('google storage', 'spotify', 'apple.com/bill', 'icloud', 'hbo', 'netflix', 'hbo max', 'patreon');

UPDATE tagging_rules SET category = 'pet_care', priority = 5 WHERE keyword IN ('animax', 'vet', 'veterinar', 'petshop', 'maxi pet');

UPDATE tagging_rules SET category = 'transport', priority = 5 WHERE keyword IN ('freenow', 'free now', 'bolt', 'petrom', 'cfr', 'stb', 'metrorex', 'lukoil', 'mol', 'omv', 'parking', 'parcare');

UPDATE tagging_rules SET category = 'utilities', priority = 5 WHERE keyword IN ('e.on', 'ppc', 'orange', 'enel');

UPDATE tagging_rules SET category = 'shopping', priority = 5 WHERE keyword IN ('emag', 'amazon', 'ikea', 'zara', 'answear', 'altex', 'flanco', 'pepco', 'h&m', 'dedeman');

UPDATE tagging_rules SET category = 'other', priority = 5 WHERE keyword IN ('help net', 'catena', 'dr max', 'farmacia tei', 'regina maria', 'medlife');

UPDATE tagging_rules SET category = 'entertainment', priority = 5 WHERE keyword IN ('cinema', 'xbox', 'cinema city', 'iabilet', 'eventim');

UPDATE tagging_rules SET category = 'rent', priority = 5 WHERE keyword = 'chirie';

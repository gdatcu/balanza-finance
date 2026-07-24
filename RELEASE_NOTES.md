# Balanza Finance v1.6.1 Release Notes

## 🛠️ Fixes & Enhancements

### 💰 Income Classification Fallback & Preserved Defaults
- Updated `Category.fromJson` and `supabaseCategoriesProvider` to guarantee that **Salary** (`salary`), **Investments** (`investments`), **Gifts** (`gifts`), **Meal Tickets** (`meal_tickets`), and **Side Hustle** (`side_hustle`) are automatically classified as `isIncome: true` regardless of remote Supabase database payload state.
- Ensures Salary, Investments, and Gifts appear strictly under **Income** and never under **Expenses** when adding new transactions or filtering dashboard views.

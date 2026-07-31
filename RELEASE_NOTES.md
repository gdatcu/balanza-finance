# Release Notes — v1.21.0

## 🏷️ Subcategories & Enhanced Auto-Tagging Engine

### 🏷️ Subcategories for ALL Categories
- **Complete Hierarchy:** Added subcategories across all 13 top-level categories:
  - **Food:** *Groceries*, *Restaurants & Dining*, *Coffee & Tea*
  - **Transport:** *Rideshare & Taxi*, *Fuel & Gas*, *Public Transit*, *Car Maintenance*
  - **Rent / Housing:** *Monthly Rent*, *Housing Maintenance*
  - **Utilities:** *Electricity*, *Internet & TV*, *Water & Heating*, *Mobile & Phone*
  - **Salary / Income:** *Main Salary*, *Meal Tickets*, *Side Hustle*, *Bonus & Rewards*
  - **Entertainment:** *Subscriptions*, *Events & Outings*, *Hobbies & Sports*
  - **Shopping:** *Clothing & Fashion*, *Gadgets & Tech*, *Home & Decor*
  - **Investments:** *Stocks & ETFs*, *Crypto*, *Real Estate*
  - **Gifts:** *Gifts Received*, *Gifts Given*
  - **Healthcare:** *Pharmacy*, *Doctor & Clinic*
  - **Travel:** *Flights & Transit*, *Hotels & Stay*
  - **Personal Care:** *Barber & Salon*
  - **Education:** *Courses & Books*

### ⚡ Dual-Level Subcategory Auto-Tagging
- **Automated Merchant Classification:** Note input auto-tags both Main Category and Subcategory simultaneously for major Romanian merchants:
  - **Uber / Bolt:** Transport → Rideshare & Taxi
  - **Froo / Mega Image / Lidl / Kaufland / Carrefour / Profi:** Food → Groceries
  - **Catena / Dr.Max / HelpNet / Sensiblu:** Healthcare → Pharmacy
  - **Orange / Vodafone / Telekom / Digi / Yoxo:** Utilities → Mobile & Phone
  - **OMV / Petrom / Rompetrol / Lukoil / Mol:** Transport → Fuel & Gas
  - **eMAG / Altex / Flanco:** Shopping → Gadgets & Tech
  - **Starbucks / 5togo / Tucano:** Food → Coffee & Tea
  - **McDonald's / KFC / Glovo / Tazz / Wolt:** Food → Restaurants & Dining

### 🎨 UI & Localization Polish
- **Title Case Formatter:** Subcategories display gracefully in Title Case across all UI dropdowns and pickers (e.g. "Rideshare Taxi", "Mobile Phone", "Barber Salon").
- **Cascading Subcategory Picker:** Subcategory dropdown dynamically updates and filters based on the selected parent category.

### 🗄️ Supabase Migration Script
- **Idempotent Migration (`supabase_subcategories_migration.sql`):** SQL migration script for Supabase DB schema updates, policy management, and tagging rules table updates.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 114/114 unit, widget, and integration tests passed!

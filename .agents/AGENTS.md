# Project Agent Rules
- Architecture: Feature-based folder structure
- State management: Provider or Riverpod
- Backend: Supabase (PostgreSQL)
- UI: Use `fl_chart` for all data visualizations

# Project Architecture: Personal Finance App

This document outlines the zero-cost technology stack and architecture decisions for building an Android personal finance application, emphasizing relational data integrity and rich data visualization.

## 1. Frontend Architecture

| Component | Technology | Rationale |
| :---- | :---- | :---- |
| Framework | Flutter (Dart) | High-performance custom UI rendering, essential for the chart-heavy requirements of a finance app. Allows for a future iOS build at no extra cost. |
| Chart Library | fl_chart | Open-source and highly customizable for pie, bar, and line charts. |
| IDE | Android Studio / VS Code | 100% free and natively supports Flutter development. |

## 2. Backend & Database

| Component | Technology | Rationale |
| :---- | :---- | :---- |
| Database Platform | Supabase | Free tier (50,000 MAU, 500MB DB space). Open-source Firebase alternative. |
| Database Type | PostgreSQL | Relational database structure is mandatory for financial ledger integrity (prevents floating-point/sync anomalies seen in NoSQL). |

## 3. Design & Planning

> * **Prototyping:** Figma (Free tier for collaborative design)  
> * **Iconography:** Material Design Icons (native to Flutter)

## 4. Version Control & CI/CD

> * **Code Hosting:** GitHub (Free private repositories)  
> * **Build Automation:** GitHub Actions (Automated Android .apk generation)

## 5. Initial Development Roadmap

> 1. **Database Schema Design:** Map out SQL tables for Users, Accounts, Categories, and Transactions.  
> 2. **Core CRUD Operations:** Build basic Flutter interfaces to add, read, update, and delete expenses connected to the Supabase backend.  
> 3. **Auth & State Management:** Implement Supabase Authentication and setup Flutter state management (e.g., Riverpod or Provider).  
> 4. **Budgets & Mathematics:** Implement logic for monthly expense aggregation and budget comparisons.  
> 5. **Data Visualization:** Integrate  
>    fl_chart to build interactive visual reports.

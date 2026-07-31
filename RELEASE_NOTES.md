# Release Notes — v1.24.1

## 🛠️ Code Maintenance & Analyzer Polish

### 🐛 Bug Fixes & Refactoring

1. **🎨 Cross-Version `Switch` Styling (`cash_flow_view.dart`)**
   - Updated `Switch` active thumb styling to use `thumbColor` with `WidgetStateProperty.resolveWith(...)`, eliminating deprecation warnings while ensuring full compatibility across Flutter SDK versions.

2. **🧹 Input Sheet Optimization (`recurring_bill_input_sheet.dart`)**
   - Cleaned up unused `subcategories` local variable.
   - Preserved `DropdownButtonFormField` `value` selection with deprecation directive for smooth SDK compatibility.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 122/122 unit, widget, and integration tests passed!

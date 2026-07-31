# Release Notes — v1.23.3

## 🛡️ Fix Dropdown Exception on Category Switch in CSV Importer

### 🛠️ Dropdown Value Sanitization (`CsvImportSheet`)
- **Fix:** Fixed a Flutter assertion error (`There should be exactly one item with [DropdownButton]'s value...`) when switching transaction parent categories or subcategories in the CSV preview modal.
- **Safe Value Guard:** Added `safeParentValue` and `safeSubValue` checks to ensure selected category IDs are strictly validated against available dropdown items before rendering.

---

## 🧪 Verification & Release Quality
- **`flutter analyze`**: 0 issues found!
- **`flutter test`**: All 120/120 unit, widget, and integration tests passed!

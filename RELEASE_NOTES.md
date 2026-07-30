# Release Notes — v1.17.4

## 🐛 Fix critic: sincronizarea cloud era complet blocată (PGRST204)

### Cauza reală
Metoda `toJson()` din modelul `Transaction` includea câmpul `is_pending_review`,
dar coloana **nu există** în tabela `transactions` din Supabase PostgreSQL.

Supabase returna eroarea `PGRST204 (Column Not Found)` la **fiecare** scriere,
astfel că nicio tranzacție nu ajungea vreodată în baza de date cloud — rămâneau
blocate în RAM-ul local al dispozitivului.

### Fix aplicat
- Adăugat `toDbJson()` în modelul `Transaction`: identic cu `toJson()` dar **fără**
  câmpul `is_pending_review`.
- Înlocuit toate apelurile `.insert(toJson())` și `.upsert(toJson())` din
  `TransactionRepository` cu `.insert(toDbJson())` și `.upsert(toDbJson())`.
- Sincronizarea cloud funcționează acum corect pe toate dispozitivele.

## 🧪 Verificare
- `flutter test`: **120/120 teste trecute (100%)**
- `flutter analyze`: **0 erori / 0 avertismente**

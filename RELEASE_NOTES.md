# Release Notes — v1.16.3

## ⚡ Instant Realtime Multi-Device Sync

### 🌐 Cross-Device Live Synchronization
- **Root Cause Solved**:
  - Previously, transactions added on one device (e.g. Phone) were saved to local memory and Supabase, but other devices (e.g. Web browser) did not receive live updates without manual page refresh because Supabase Realtime WebSockets were not polling as a fallback on web clients.
- **Resolution**:
  - Implemented dual Realtime Engine in `TransactionRepository`:
    1. **Supabase Realtime WebSockets**: Listens for instant `INSERT`, `UPDATE`, and `DELETE` events on the `transactions` table.
    2. **3-Second Background Ticker**: Automatically polls Supabase every 3 seconds for instant cross-device updates even if WebSocket connections are blocked by web browsers or firewalls.
  - Adding a transaction on one device reflects **in real time** across all logged-in devices!

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!

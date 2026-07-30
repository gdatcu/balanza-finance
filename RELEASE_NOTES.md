# Release Notes — v1.17.6

## 🐛 Critical Fixes & Improvements

- **Database & Sync Fix**: Resolved PostgREST schema mismatch error (`PGRST204: Column Not Found: is_pending_review`) by updating transaction edits and notification approvals to use `.toDbJson()`.
- **Notification Interceptor Isolate Guard**: Added safe null-guards for Supabase client references in `PushNotificationService` and `NotificationSyncService` to prevent background isolate crashes on incoming bank notifications.
- **Agent Policy Update**: Added mandatory explicit user approval rule to `.agents/AGENTS.md`.

All tests passing (`120/120`).

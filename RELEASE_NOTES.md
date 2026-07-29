# Release Notes — v1.15.3

## 🛠️ Bank Auto-Sync Diagnostics & On-Device Testing Tool

### 🔍 Dedicated Diagnostics Screen ("Diagnostic Notificări Bancare")
- **Access**: Open **Settings ⚙️ -> Bank Auto-Sync -> Tap the Bug Icon 🐛**.
- **Live Status Monitoring**:
  - Checks if Android Notification Access permission is granted.
  - Checks if background Listener Service is running.
  - Displays the active bound User ID.
- **On-Device Notification Simulation & Testing**:
  - **Test BCR Încasare (+28.94 RON)**: Simulates the exact BCR income notification format.
  - **Test BCR Plată Card (-89.90 RON)**: Simulates BCR card purchase format.
  - **Test Revolut Plată (-45.00 RON)**: Simulates Revolut purchase format.
  - **Test Custom Notification**: Enter any title and body text to test parsing instantly on your phone.
- **Captured Notifications Audit Log**:
  - Displays the last 20 raw bank notifications received by your device directly from the `debug_notifications` table!

### ⚡ Dual-Isolate Event Delivery
- Added a foreground UI isolate listener (`receivePort`) alongside the background isolate listener, ensuring 100% notification delivery whether the app is in the foreground, background, or closed.

---

## 🧪 Verification
- **`flutter test`**: 118/118 tests passed!
- **`flutter analyze`**: 0 issues found!

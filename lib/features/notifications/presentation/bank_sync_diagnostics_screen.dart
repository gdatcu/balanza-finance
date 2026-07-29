import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_sync_service.dart';
import '../../../core/utils/notification_parser.dart';
import '../../transactions/providers/transaction_provider.dart';

class BankSyncDiagnosticsScreen extends ConsumerStatefulWidget {
  const BankSyncDiagnosticsScreen({super.key});

  @override
  ConsumerState<BankSyncDiagnosticsScreen> createState() => _BankSyncDiagnosticsScreenState();
}

class _BankSyncDiagnosticsScreenState extends ConsumerState<BankSyncDiagnosticsScreen> {
  bool _hasPermission = false;
  bool _isRunning = false;
  String _savedUserId = '';
  bool _isLoading = true;

  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _customBodyController = TextEditingController();
  final String _customPackage = 'ro.bcr.georgego';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    _customBodyController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final permission = await NotificationSyncService.isPermissionGranted();
    final running = (await NotificationSyncService.isPermissionGranted())
        ? (await NotificationSyncService.startListener())
        : false;

    String userId = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('last_authenticated_user_id') ?? '';
    } catch (_) {}
    if (userId.isEmpty) {
      userId = Supabase.instance.client.auth.currentUser?.id ?? 'Not logged in';
    }

    if (mounted) {
      setState(() {
        _hasPermission = permission;
        _isRunning = running;
        _savedUserId = userId;
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateNotification({
    required String packageName,
    required String title,
    required String body,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final parserResult = NotificationParser.parseNotification(
      packageName: packageName,
      title: title,
      body: body,
    );

    final success = await NotificationSyncService().handleNotificationEvent(
      packageName: packageName,
      title: title,
      body: body,
    );

    if (mounted) {
      ref.invalidate(pendingTransactionsProvider);
      if (success && parserResult != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '✅ Simulated successfully!\nParsed: ${parserResult.isIncome ? '+' : '-'}${parserResult.amount} ${parserResult.currency} (${parserResult.merchant})',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Interception result: False\nTitle: "$title"\nBody: "$body"',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRo = Localizations.localeOf(context).languageCode == 'ro';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isRo ? 'Diagnostic Notificări Bancare' : 'Bank Sync Diagnostics',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Service Status Card
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isRunning ? Icons.check_circle : Icons.warning_amber_rounded,
                              color: _isRunning ? Colors.green : Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isRo ? 'Stare Serviciu Fundal' : 'Background Service Status',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.white24),
                        _buildStatusRow(
                          isRo ? 'Permisiune Notificări Android' : 'Android Notification Permission',
                          _hasPermission ? (isRo ? 'Acordată ✅' : 'Granted ✅') : (isRo ? 'Neacordată ❌' : 'Denied ❌'),
                          _hasPermission ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 8),
                        _buildStatusRow(
                          isRo ? 'Serviciu Listener În Rulare' : 'Listener Service Running',
                          _isRunning ? (isRo ? 'Activ ✅' : 'Active ✅') : (isRo ? 'Oprit ⚠️' : 'Stopped ⚠️'),
                          _isRunning ? Colors.green : Colors.amber,
                        ),
                        const SizedBox(height: 8),
                        _buildStatusRow(
                          isRo ? 'ID Utilizator Înregistrat' : 'Bound User ID',
                          _savedUserId.length > 12 ? '${_savedUserId.substring(0, 12)}...' : _savedUserId,
                          Colors.cyan,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.settings),
                                label: Text(isRo ? 'Setări Permisiuni' : 'Permission Settings'),
                                onPressed: () async {
                                  await NotificationSyncService.openPermissionSettings();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.play_arrow),
                                label: Text(isRo ? 'Repornește Serviciu' : 'Restart Service'),
                                onPressed: () async {
                                  await NotificationSyncService.startListener();
                                  await _checkStatus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Interactive Testing & Simulation Section
                Text(
                  isRo ? 'Simulează / Testează Notificare Bancară' : 'Simulate / Test Bank Notification',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  isRo
                      ? 'Apasă pe un buton pentru a testa parser-ul direct pe telefonul tău:'
                      : 'Tap a button below to test the parser directly on your device:',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.add_circle, color: Colors.green, size: 18),
                      label: const Text('BCR Încasare (+28.94 RON)'),
                      backgroundColor: const Color(0xFF0F172A),
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: () => _simulateNotification(
                        packageName: 'ro.bcr.georgego',
                        title: 'Info incasari',
                        body: '🥳🥳 Ai primit 28.94 RON in contul George Standard de la Datcu George Cristian in 29/07/2026 15:59.',
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 18),
                      label: const Text('BCR Plată Card (-89.90 RON)'),
                      backgroundColor: const Color(0xFF0F172A),
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: () => _simulateNotification(
                        packageName: 'ro.bcr.georgego',
                        title: 'George BCR',
                        body: 'Plata cu cardul - 89.90 RON la Kaufland din contul RO123.',
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.account_balance_wallet, color: Colors.cyan, size: 18),
                      label: const Text('Revolut Plată (-45.00 RON)'),
                      backgroundColor: const Color(0xFF0F172A),
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: () => _simulateNotification(
                        packageName: 'com.revolut.office',
                        title: 'Revolut',
                        body: 'Paid 45.00 RON to Starbucks',
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.edit, color: Colors.amber, size: 18),
                      label: Text(isRo ? 'Test Text Personalizat' : 'Test Custom Text'),
                      backgroundColor: const Color(0xFF0F172A),
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: _showCustomTestDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 3. Captured Raw Notifications Audit Log
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRo ? 'Jurnal Audit Notificări Capturate' : 'Captured Notifications Audit Log',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: () => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchDebugLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final logs = snapshot.data ?? [];
                    if (logs.isEmpty) {
                      return Card(
                        color: const Color(0xFF0F172A),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              isRo
                                  ? 'Nicio notificare stocată în jurnal. Primește o notificare pe telefon sau simulează una de mai sus.'
                                  : 'No notification logs found. Trigger a notification on device or simulate one above.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: logs.map((log) {
                        final pkg = log['package_name'] ?? '';
                        final title = log['raw_title'] ?? '';
                        final body = log['raw_body'] ?? '';
                        final dateStr = log['created_at'] != null
                            ? DateTime.parse(log['created_at']).toLocal().toString().substring(0, 16)
                            : '';

                        return Card(
                          color: const Color(0xFF1E293B),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              pkg.contains('bcr') || pkg.contains('george')
                                  ? Icons.account_balance
                                  : pkg.contains('revolut')
                                      ? Icons.flash_on
                                      : Icons.notifications,
                              color: Colors.cyan,
                            ),
                            title: Text(
                              '$title ($pkg)',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(body, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDebugLogs() async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('debug_notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(20);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  void _showCustomTestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Test Custom Notification', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customTitleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                hintText: 'e.g. Info incasari',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customBodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notification Body Text',
                hintText: 'e.g. Ai primit 50.00 RON in contul...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulateNotification(
                packageName: _customPackage,
                title: _customTitleController.text.trim(),
                body: _customBodyController.text.trim(),
              );
            },
            child: const Text('Simulate'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:balanza/l10n/app_localizations.dart';
import '../../../../models/net_worth_item.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/net_worth_provider.dart';

class NetWorthView extends ConsumerWidget {
  const NetWorthView({super.key});

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddNetWorthItemSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorthAsync = ref.watch(netWorthListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Midnight Slate Blue
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.netWorth,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: netWorthAsync.when(
            data: (items) {
              final assets = items.where((item) => item.type == NetWorthType.asset).toList();
              final liabilities = items.where((item) => item.type == NetWorthType.liability).toList();

              final totalAssets = assets.fold<double>(0.0, (sum, item) => sum + item.balance);
              final totalLiabilities = liabilities.fold<double>(0.0, (sum, item) => sum + item.balance);
              final netWorthValue = totalAssets - totalLiabilities;

              return ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                children: [
                  _buildHeader(context, netWorthValue, totalAssets, totalLiabilities),
                  const SizedBox(height: 24),
                  
                  // Assets Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.assets.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF10B981), // Sage Mint Green
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(totalAssets),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, indent: 24, endIndent: 24),
                  if (assets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        AppLocalizations.of(context)!.noAssetsRecorded,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  else
                    ...assets.map((item) => _buildRow(context, ref, item)),

                  const SizedBox(height: 32),

                  // Liabilities Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.liabilities.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFF7A5A), // Coral Orange
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(totalLiabilities),
                          style: const TextStyle(
                            color: Color(0xFFFF7A5A),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, indent: 24, endIndent: 24),
                  if (liabilities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        AppLocalizations.of(context)!.noLiabilitiesRecorded,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  else
                    ...liabilities.map((item) => _buildRow(context, ref, item)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF7A5A)),
                  const SizedBox(height: 16),
                  Text('Something went wrong: $err', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(netWorthListProvider),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A5A)),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: const Color(0xFFFF7A5A),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double netWorth, double assets, double liabilities) {
    final isPositive = netWorth >= 0;
    final accentColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFFF7A5A);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E293B), // Dark Slate Grey
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.overallNetWorth.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(netWorth),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.totalAssets, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(assets),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('-', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.liabilities, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(liabilities),
                          style: const TextStyle(
                            color: Color(0xFFFF7A5A),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('=', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.netWorth, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(netWorth),
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, NetWorthItem item) {
    final accentColor = item.type == NetWorthType.asset ? const Color(0xFF10B981) : const Color(0xFFFF7A5A);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFFF7A5A),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteItem),
            content: Text(AppLocalizations.of(context)!.confirmDelete),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Color(0xFFFF7A5A)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(netWorthListProvider.notifier).delete(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.itemDeleted),
            backgroundColor: const Color(0xFF1E293B),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              CurrencyFormatter.format(item.balance),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNetWorthItemSheet extends ConsumerStatefulWidget {
  const AddNetWorthItemSheet({super.key});

  @override
  ConsumerState<AddNetWorthItemSheet> createState() => _AddNetWorthItemSheetState();
}

class _AddNetWorthItemSheetState extends ConsumerState<AddNetWorthItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isAsset = true;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final item = NetWorthItem(
        id: const Uuid().v4(),
        userId: '', // set in repo
        name: _nameController.text.trim(),
        balance: double.parse(_amountController.text.trim()),
        type: _isAsset ? NetWorthType.asset : NetWorthType.liability,
        createdAt: DateTime.now(),
      );

      ref.read(netWorthListProvider.notifier).add(item);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final activeColor = _isAsset ? const Color(0xFF10B981) : const Color(0xFFFF7A5A);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + keyboardInset,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // Dark Slate
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.addNetWorthItem,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // Switch Toggle
              SwitchListTile(
                title: Text(
                  _isAsset
                      ? '${AppLocalizations.of(context)!.type}: ${AppLocalizations.of(context)!.typeAsset}'
                      : '${AppLocalizations.of(context)!.type}: ${AppLocalizations.of(context)!.typeLiability}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                secondary: Icon(
                  _isAsset ? Icons.account_balance : Icons.credit_card,
                  color: activeColor,
                ),
                value: _isAsset,
                activeColor: const Color(0xFF10B981),
                inactiveThumbColor: const Color(0xFFFF7A5A),
                inactiveTrackColor: const Color(0xFFFF7A5A).withValues(alpha: 0.2),
                onChanged: (val) {
                  setState(() {
                    _isAsset = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.nameFieldLabel,
                  prefixIcon: Icon(Icons.edit, color: activeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amountFieldLabel,
                  prefixIcon: Icon(Icons.attach_money, color: activeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterAmount;
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return AppLocalizations.of(context)!.pleaseEnterValidPositiveNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.addItem,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/financial_health_provider.dart';

/// Interactive UI card displaying Financial Health Score (0-100) and breakdown pillars.
class FinancialHealthCard extends ConsumerWidget {
  const FinancialHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(financialHealthProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final isRo = locale == 'ro';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: health.levelColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.monitor_heart_outlined, color: health.levelColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRo ? 'Scor Sănătate Financiară' : 'Financial Health Score',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        isRo ? 'Calculat din 4 piloni de buget' : 'Calculated across 4 key pillars',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),

              // Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: health.levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: health.levelColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  health.level.toUpperCase(),
                  style: TextStyle(color: health.levelColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Score Ring & Meter
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: health.overallScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(health.levelColor),
                    ),
                  ),
                  Text(
                    '${health.overallScore}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Pillars Quick Grid
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildPillarChip(
                          label: isRo ? 'Economii' : 'Savings Rate',
                          points: '${health.savingsRatePoints}/30',
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _buildPillarChip(
                          label: isRo ? 'Buget Pacing' : 'Budget Pacing',
                          points: '${health.budgetPacingPoints}/25',
                          color: const Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPillarChip(
                          label: isRo ? 'Tampon Urgență' : 'Emergency Buffer',
                          points: '${health.emergencyBufferPoints}/25',
                          color: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8),
                        _buildPillarChip(
                          label: isRo ? 'Rată Datorii' : 'Debt Ratio',
                          points: '${health.debtRatioPoints}/20',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (health.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Text(
              isRo ? 'Recomandări pentru Îmbunătățire:' : 'Recommendations to Improve Score:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ...health.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(rec.icon, color: const Color(0xFF60A5FA), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRo ? rec.titleRo : rec.titleEn,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            isRo ? rec.bodyRo : rec.bodyEn,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillarChip({required String label, required String points, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              points,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

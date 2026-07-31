import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/cash_flow_projection_provider.dart';

class CashFlowProjectionChart extends StatelessWidget {
  final CashFlowSummary summary;

  const CashFlowProjectionChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.dailyPoints.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No cash flow data available', style: TextStyle(color: Colors.white38))),
      );
    }

    final points = summary.dailyPoints;
    final now = DateTime.now();

    final actualPoints = points.where((p) => !p.isProjected).toList();
    final projectedPoints = points.where((p) => p.isProjected || p.date.day == now.day).toList();

    double minY = points.map((p) => p.balance).reduce((a, b) => a < b ? a : b);
    double maxY = points.map((p) => p.balance).reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 100;
      maxY += 100;
    }
    // Add padding to chart bounds
    final yRange = maxY - minY;
    minY -= yRange * 0.1;
    maxY += yRange * 0.1;

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.show_chart, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cash Flow Projection',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendDot(const Color(0xFF10B981), 'Actual'),
                  const SizedBox(width: 12),
                  _buildLegendDot(const Color(0xFF3B82F6), 'Projected'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: points.length.toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          CurrencyFormatter.formatCompact(val),
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (val, meta) {
                        final day = val.toInt();
                        if (day < 1 || day > points.length) return const SizedBox.shrink();
                        return Text(
                          '$day',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.spotIndex;
                        if (idx >= points.length) return null;
                        final pt = points[idx];
                        final dayStr = '${pt.date.day}/${pt.date.month}';
                        final billText = pt.billNames.isNotEmpty ? '\n📌 ${pt.billNames.join(', ')}' : '';

                        return LineTooltipItem(
                          '$dayStr: ${CurrencyFormatter.format(pt.balance)}$billText',
                          TextStyle(
                            color: pt.isProjected ? const Color(0xFF60A5FA) : const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // Actual Line (Solid Green)
                  if (actualPoints.isNotEmpty)
                    LineChartBarData(
                      spots: actualPoints.map((p) => FlSpot(p.date.day.toDouble(), p.balance)).toList(),
                      isCurved: true,
                      color: const Color(0xFF10B981),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final pt = points.firstWhere((p) => p.date.day == spot.x.toInt(), orElse: () => points.first);
                          if (pt.billNames.isNotEmpty) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: const Color(0xFFF59E0B),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          }
                          return FlDotCirclePainter(radius: 2, color: const Color(0xFF10B981), strokeWidth: 0);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      ),
                    ),

                  // Projected Line (Blue)
                  if (projectedPoints.isNotEmpty)
                    LineChartBarData(
                      spots: projectedPoints.map((p) => FlSpot(p.date.day.toDouble(), p.balance)).toList(),
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 3,
                      dashArray: [6, 4],
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final pt = points.firstWhere((p) => p.date.day == spot.x.toInt(), orElse: () => points.first);
                          if (pt.billNames.isNotEmpty) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: const Color(0xFFF59E0B),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          }
                          return FlDotCirclePainter(radius: 2, color: const Color(0xFF3B82F6), strokeWidth: 0);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

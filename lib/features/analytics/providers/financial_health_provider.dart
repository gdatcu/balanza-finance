import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/net_worth_item.dart';
import '../../net_worth/providers/net_worth_provider.dart';
import '../../transactions/presentation/categories_data.dart';
import '../../transactions/providers/transaction_provider.dart';

class FinancialRecommendation {
  final String titleEn;
  final String titleRo;
  final String bodyEn;
  final String bodyRo;
  final IconData icon;

  const FinancialRecommendation({
    required this.titleEn,
    required this.titleRo,
    required this.bodyEn,
    required this.bodyRo,
    required this.icon,
  });
}

class FinancialHealthScore {
  final int overallScore; // 0 - 100
  final String level; // Excellent, Good, Fair, Needs Attention
  final Color levelColor;

  // Pillar 1: Savings Rate (Max 30)
  final double savingsRate;
  final int savingsRatePoints;

  // Pillar 2: Budget Pacing (Max 25)
  final double budgetPacing;
  final int budgetPacingPoints;

  // Pillar 3: Emergency Buffer (Max 25)
  final double emergencyMonths;
  final int emergencyBufferPoints;

  // Pillar 4: Debt-to-Income Ratio (Max 20)
  final double debtRatio;
  final int debtRatioPoints;

  final List<FinancialRecommendation> recommendations;

  const FinancialHealthScore({
    required this.overallScore,
    required this.level,
    required this.levelColor,
    required this.savingsRate,
    required this.savingsRatePoints,
    required this.budgetPacing,
    required this.budgetPacingPoints,
    required this.emergencyMonths,
    required this.emergencyBufferPoints,
    required this.debtRatio,
    required this.debtRatioPoints,
    required this.recommendations,
  });
}

final financialHealthProvider = Provider<FinancialHealthScore>((ref) {
  final transactions = ref.watch(transactionListProvider).value ?? [];
  final monthlyBudget = 5000.0;
  final netWorthItems = ref.watch(netWorthListProvider).value ?? [];

  final categories = ref.watch(supabaseCategoriesProvider).value ?? defaultCategories;

  final now = DateTime.now();
  final currentMonthTxs = transactions.where((t) => t.date.month == now.month && t.date.year == now.year).toList();

  double incomeSum = 0.0;
  double expenseSum = 0.0;
  double debtInstallmentsSum = 0.0;

  for (final tx in currentMonthTxs) {
    if (tx.amount > 0) {
      incomeSum += tx.amount;
    } else {
      final amt = tx.amount.abs();
      expenseSum += amt;

      // Check debt/loan category
      final cat = categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => categories.first);
      if (cat.name.toLowerCase().contains('credit') || cat.name.toLowerCase().contains('rate')) {
        debtInstallmentsSum += amt;
      }
    }
  }

  // Fallback defaults for income & expenses if no monthly txs logged yet
  final effectiveIncome = incomeSum > 0 ? incomeSum : 6000.0;
  final effectiveExpense = expenseSum > 0 ? expenseSum : 3500.0;

  // 1. Savings Rate Score (Max 30 pts)
  final netSavings = effectiveIncome - effectiveExpense;
  final savingsRate = (netSavings / effectiveIncome) * 100;
  int savingsPts = 0;
  if (savingsRate >= 30) {
    savingsPts = 30;
  } else if (savingsRate >= 20) {
    savingsPts = 25;
  } else if (savingsRate >= 10) {
    savingsPts = 15;
  } else if (savingsRate > 0) {
    savingsPts = 8;
  }

  // 2. Budget Pacing Score (Max 25 pts)
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final expectedPacingPct = (now.day / daysInMonth) * 100;
  final actualPacingPct = (effectiveExpense / monthlyBudget) * 100;
  final pacingDiff = actualPacingPct - expectedPacingPct;

  int pacingPts = 25;
  if (pacingDiff > 25) {
    pacingPts = 5;
  } else if (pacingDiff > 10) {
    pacingPts = 12;
  } else if (pacingDiff > 0) {
    pacingPts = 18;
  }

  // 3. Emergency Buffer Score (Max 25 pts)
  double totalLiquidAssets = 0.0;
  for (final item in netWorthItems) {
    if (item.type == NetWorthType.asset) {
      totalLiquidAssets += item.balance;
    }
  }

  final monthlyBurn = effectiveExpense > 0 ? effectiveExpense : 3000.0;
  final emergencyMonths = totalLiquidAssets / monthlyBurn;

  int emergencyPts = 5;
  if (emergencyMonths >= 6) {
    emergencyPts = 25;
  } else if (emergencyMonths >= 3) {
    emergencyPts = 18;
  } else if (emergencyMonths >= 1) {
    emergencyPts = 12;
  }

  // 4. Debt-to-Income Ratio Score (Max 20 pts)
  final debtRatio = (debtInstallmentsSum / effectiveIncome) * 100;
  int debtPts = 20;
  if (debtRatio > 35) {
    debtPts = 0;
  } else if (debtRatio > 20) {
    debtPts = 8;
  } else if (debtRatio > 10) {
    debtPts = 14;
  }

  final totalScore = (savingsPts + pacingPts + emergencyPts + debtPts).clamp(0, 100);

  String level;
  Color levelColor;
  if (totalScore >= 85) {
    level = 'Excellent';
    levelColor = const Color(0xFF10B981);
  } else if (totalScore >= 70) {
    level = 'Good';
    levelColor = const Color(0xFF3B82F6);
  } else if (totalScore >= 50) {
    level = 'Fair';
    levelColor = const Color(0xFFF59E0B);
  } else {
    level = 'Needs Attention';
    levelColor = const Color(0xFFEF4444);
  }

  final recommendations = <FinancialRecommendation>[];
  if (savingsPts < 25) {
    recommendations.add(
      const FinancialRecommendation(
        titleEn: 'Boost Your Savings Rate',
        titleRo: 'Apreciază Rata de Economisire',
        bodyEn: 'Try automating 20% of your income into a savings goal right on payday.',
        bodyRo: 'Încearcă să direcționezi automat 20% din venituri către un obiectiv de economii.',
        icon: Icons.savings_outlined,
      ),
    );
  }

  if (pacingPts < 18) {
    recommendations.add(
      const FinancialRecommendation(
        titleEn: 'Slow Down Budget Velocity',
        titleRo: 'Încetinește Ritmul Bugetului',
        bodyEn: 'Your spending is pacing faster than the calendar month. Review discretionary expenses.',
        bodyRo: 'Cheltuielile tale depășesc ritmul zilelor din lună. Verifică cheltuielile opționale.',
        icon: Icons.speed_outlined,
      ),
    );
  }

  if (emergencyPts < 18) {
    recommendations.add(
      const FinancialRecommendation(
        titleEn: 'Build 3-6 Month Emergency Fund',
        titleRo: 'Creează Fond de Urgență (3-6 luni)',
        bodyEn: 'You currently have under 3 months of liquid buffer. Add an Emergency asset to Net Worth.',
        bodyRo: 'Ai sub 3 luni de tampon lichid. Adaugă un activ de Urgență în Valoarea Netă.',
        icon: Icons.shield_outlined,
      ),
    );
  }

  return FinancialHealthScore(
    overallScore: totalScore,
    level: level,
    levelColor: levelColor,
    savingsRate: savingsRate,
    savingsRatePoints: savingsPts,
    budgetPacing: actualPacingPct,
    budgetPacingPoints: pacingPts,
    emergencyMonths: emergencyMonths,
    emergencyBufferPoints: emergencyPts,
    debtRatio: debtRatio,
    debtRatioPoints: debtPts,
    recommendations: recommendations,
  );
});

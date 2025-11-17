import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../models/savings_data.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late SavingsData _savingsData;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _savingsData = StorageService.getSavingsData();
      _transactions = StorageService.getTransactions();
    });
  }

  Map<String, double> _getCategorySpending() {
    final Map<String, double> spending = {};
    for (var transaction in _transactions) {
      if (!transaction.isIncome) {
        spending[transaction.category] =
            (spending[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return spending;
  }

  List<Map<String, dynamic>> _getWeeklySpending() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final List<Map<String, dynamic>> weeklyData = [];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayTransactions = _transactions.where((t) {
        return t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day &&
            !t.isIncome;
      }).toList();

      final total = dayTransactions.fold<double>(
        0,
        (sum, t) => sum + t.amount,
      );

      weeklyData.add({
        'day': DateFormat('E').format(date),
        'amount': total,
      });
    }

    return weeklyData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categorySpending = _getCategorySpending();
    final weeklyData = _getWeeklySpending();
    final maxWeekly = weeklyData.isEmpty
        ? 0.0
        : weeklyData.map((d) => d['amount'] as double).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Monthly Overview
              _buildCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Budget',
                          '\$${_savingsData.monthlyBudget.toStringAsFixed(2)}',
                          Icons.account_balance,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          context,
                          'Spent',
                          '\$${_savingsData.monthlySpent.toStringAsFixed(2)}',
                          Icons.shopping_cart,
                          Colors.red,
                        ),
                        _buildStatItem(
                          context,
                          'Remaining',
                          '\$${_savingsData.monthlyRemaining.toStringAsFixed(2)}',
                          Icons.savings,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _savingsData.monthlyBudget > 0
                          ? (_savingsData.monthlySpent / _savingsData.monthlyBudget).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _savingsData.monthlySpent > _savingsData.monthlyBudget
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Weekly Spending Chart
              _buildCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Spending',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxWeekly > 0 ? maxWeekly * 1.2 : 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < weeklyData.length) {
                                    return Text(
                                      weeklyData[index]['day'],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: weeklyData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: data['amount'] as double,
                                  color: theme.colorScheme.primary,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Breakdown
              _buildCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending by Category',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (categorySpending.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No spending data yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ...categorySpending.entries.map((entry) {
                        final total = categorySpending.values.reduce((a, b) => a + b);
                        final percentage = (entry.value / total * 100);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: entry.value / total,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Achievements
              _buildCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAchievement(
                      context,
                      '🔥 Streak Master',
                      'Visit ${_savingsData.streakDays} days in a row',
                      Icons.local_fire_department,
                      _savingsData.streakDays >= 7,
                    ),
                    const SizedBox(height: 12),
                    _buildAchievement(
                      context,
                      '💰 Saver',
                      'Save \$${_savingsData.totalSavings.toStringAsFixed(2)}',
                      Icons.savings,
                      _savingsData.totalSavings >= 1000,
                    ),
                    const SizedBox(height: 12),
                    _buildAchievement(
                      context,
                      '🌳 Tree Keeper',
                      'Keep your tree healthy',
                      Icons.park,
                      _savingsData.treeHealth >= 0.7,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Set Budget Button
              if (_savingsData.monthlyBudget == 0)
                ElevatedButton.icon(
                  onPressed: () => _showBudgetDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Set Monthly Budget'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievement(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool unlocked,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked
                ? theme.colorScheme.primaryContainer
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: unlocked ? theme.colorScheme.primary : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? null : Colors.grey[600],
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (unlocked)
          Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
      ],
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(controller.text);
              if (budget != null && budget > 0) {
                final updatedData = _savingsData.copyWith(monthlyBudget: budget);
                StorageService.saveSavingsData(updatedData);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}


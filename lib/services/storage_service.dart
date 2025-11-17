import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/savings_data.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Transactions
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final json = transactions.map((t) => t.toJson()).toList();
    await _prefs?.setString('transactions', jsonEncode(json));
  }

  static List<Transaction> getTransactions() {
    try {
      final jsonString = _prefs?.getString('transactions');
      if (jsonString == null) return [];
      final json = jsonDecode(jsonString) as List;
      return json.map((j) => Transaction.fromJson(j)).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  // Savings Data
  static Future<void> saveSavingsData(SavingsData data) async {
    await _prefs?.setString('savings_data', jsonEncode(data.toJson()));
  }

  static SavingsData getSavingsData() {
    try {
      final jsonString = _prefs?.getString('savings_data');
      if (jsonString == null) {
        return SavingsData(
          totalSavings: 0.0,
          monthlyBudget: 0.0,
          monthlySpent: 0.0,
          streakDays: 0,
          lastVisitDate: DateTime.now(),
          achievements: [],
        );
      }
      final json = jsonDecode(jsonString);
      return SavingsData.fromJson(json);
    } catch (e) {
      print('Error loading savings data: $e');
      return SavingsData(
        totalSavings: 0.0,
        monthlyBudget: 0.0,
        monthlySpent: 0.0,
        streakDays: 0,
        lastVisitDate: DateTime.now(),
        achievements: [],
      );
    }
  }

  // Update streak
  static Future<int> updateStreak() async {
    final data = getSavingsData();
    final now = DateTime.now();
    final lastVisit = data.lastVisitDate;

    // Normalize dates to midnight for accurate comparison
    final today = DateTime(now.year, now.month, now.day);
    final lastVisitDate = DateTime(lastVisit.year, lastVisit.month, lastVisit.day);

    // Calculate difference in days
    final daysDifference = today.difference(lastVisitDate).inDays;

    int newStreak = data.streakDays;

    if (daysDifference == 0) {
      // Already visited today
      return newStreak;
    } else if (daysDifference == 1) {
      // Consecutive day - increase streak
      newStreak += 1;
    } else if (daysDifference > 1) {
      // Streak broken - reset to 1
      newStreak = 1;
    }

    final updatedData = data.copyWith(
      streakDays: newStreak,
      lastVisitDate: now,
    );
    await saveSavingsData(updatedData);
    return newStreak;
  }
}


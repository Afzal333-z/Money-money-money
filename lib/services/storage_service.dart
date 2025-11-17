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
    final jsonString = _prefs?.getString('transactions');
    if (jsonString == null) return [];
    final json = jsonDecode(jsonString) as List;
    return json.map((j) => Transaction.fromJson(j)).toList();
  }

  // Savings Data
  static Future<void> saveSavingsData(SavingsData data) async {
    await _prefs?.setString('savings_data', jsonEncode(data.toJson()));
  }

  static SavingsData getSavingsData() {
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
  }

  // Update streak
  static Future<int> updateStreak() async {
    final data = getSavingsData();
    final now = DateTime.now();
    final lastVisit = data.lastVisitDate;
    
    int newStreak = data.streakDays;
    
    if (lastVisit.year == now.year && 
        lastVisit.month == now.month && 
        lastVisit.day == now.day) {
      // Already visited today
      return newStreak;
    } else if (lastVisit.year == now.year && 
               lastVisit.month == now.month && 
               lastVisit.day == now.day - 1) {
      // Consecutive day
      newStreak += 1;
    } else {
      // Streak broken
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


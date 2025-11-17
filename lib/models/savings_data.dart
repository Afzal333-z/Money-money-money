class SavingsData {
  final double totalSavings;
  final double monthlyBudget;
  final double monthlySpent;
  final int streakDays;
  final DateTime lastVisitDate;
  final List<String> achievements;

  SavingsData({
    required this.totalSavings,
    required this.monthlyBudget,
    required this.monthlySpent,
    required this.streakDays,
    required this.lastVisitDate,
    required this.achievements,
  });

  double get monthlyRemaining => monthlyBudget - monthlySpent;
  double get savingsPercentage => monthlyBudget > 0 ? (monthlyRemaining / monthlyBudget) * 100 : 0;
  
  // Tree health based on savings (0.0 to 1.0)
  double get treeHealth {
    if (totalSavings <= 0) return 0.0;
    if (totalSavings >= monthlyBudget * 3) return 1.0;
    return (totalSavings / (monthlyBudget * 3)).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSavings': totalSavings,
      'monthlyBudget': monthlyBudget,
      'monthlySpent': monthlySpent,
      'streakDays': streakDays,
      'lastVisitDate': lastVisitDate.toIso8601String(),
      'achievements': achievements,
    };
  }

  factory SavingsData.fromJson(Map<String, dynamic> json) {
    return SavingsData(
      totalSavings: json['totalSavings']?.toDouble() ?? 0.0,
      monthlyBudget: json['monthlyBudget']?.toDouble() ?? 0.0,
      monthlySpent: json['monthlySpent']?.toDouble() ?? 0.0,
      streakDays: json['streakDays'] ?? 0,
      lastVisitDate: DateTime.parse(json['lastVisitDate'] ?? DateTime.now().toIso8601String()),
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  SavingsData copyWith({
    double? totalSavings,
    double? monthlyBudget,
    double? monthlySpent,
    int? streakDays,
    DateTime? lastVisitDate,
    List<String>? achievements,
  }) {
    return SavingsData(
      totalSavings: totalSavings ?? this.totalSavings,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlySpent: monthlySpent ?? this.monthlySpent,
      streakDays: streakDays ?? this.streakDays,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      achievements: achievements ?? this.achievements,
    );
  }
}


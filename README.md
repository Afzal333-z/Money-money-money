# Money Money - Your Personal Finance Tree 🌳

A beautiful, modern Flutter app for managing your money spending with a unique visual tree that grows and thrives as you save more money!

## Features

### 🌳 Visual Money Tree
- **Dynamic Tree Growth**: Watch your tree grow bushy and healthy as you save money
- **Visual Feedback**: The tree withers and loses leaves when money is low
- **Animated**: Smooth animations and wind effects make the tree come alive

### 💰 Money Management
- Track income and expenses
- Set monthly budgets
- View spending by category
- Weekly spending charts
- Recent transactions list

### 🔥 Daily Engagement
- **Streak Tracking**: Build a daily visit streak
- **Achievements**: Unlock achievements for milestones
- **Beautiful UI**: Modern, gradient-based design that encourages daily use

### 📊 Statistics & Analytics
- Monthly overview with budget tracking
- Weekly spending visualization
- Category breakdown with percentages
- Achievement system

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd money_money
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## How It Works

### The Tree Health System
The tree's health is calculated based on your total savings:
- **0% Health**: No savings - tree is bare and withered
- **50% Health**: Moderate savings - tree has some leaves
- **100% Health**: High savings (3x monthly budget) - tree is bushy and thriving

### Daily Streaks
Visit the app daily to build your streak! The streak counter tracks consecutive days you've opened the app.

### Saving Money
- Add income to increase your total savings
- Add expenses to track spending
- The tree reflects your financial health in real-time

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── transaction.dart     # Transaction data model
│   └── savings_data.dart    # Savings and budget data model
├── screens/
│   ├── home_screen.dart     # Main screen with tree
│   ├── add_transaction_screen.dart  # Add income/expense
│   └── stats_screen.dart    # Statistics and analytics
├── services/
│   └── storage_service.dart # Local storage management
└── widgets/
    └── money_tree.dart      # Animated tree widget
```

## Technologies Used

- **Flutter**: Cross-platform framework
- **shared_preferences**: Local data persistence
- **fl_chart**: Beautiful charts and graphs
- **google_fonts**: Modern typography
- **intl**: Date and number formatting

## Design Philosophy

The app is designed with the following principles:
1. **Visual Motivation**: The tree provides immediate visual feedback on financial health
2. **Daily Engagement**: Streaks and achievements encourage regular use
3. **Modern UI**: Clean, gradient-based design with smooth animations
4. **Simplicity**: Easy to use, focused on core functionality

## Future Enhancements

- Cloud sync across devices
- Multiple currency support
- Export transactions to CSV
- Budget alerts and notifications
- More tree customization options
- Social sharing of achievements

## License

This project is open source and available for personal use.

---

Made with ❤️ and Flutter


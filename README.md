# Personal Budgeting Tracker

A Flutter mobile application for tracking personal income and expenses with SQLite local storage, monthly summaries, and an interactive donut chart visualization.

## Features

- **Splash Screen** – Animated splash with session persistence
- **Login Screen** – Credential-based login with SharedPreferences session
- **Dashboard** – Monthly financial overview with collapsible SliverAppBar
- **Balance Summary** – Real-time total balance, income, and expense display
- **Month Navigation** – Browse past months; future months are restricted
- **Donut Chart** – Interactive pie chart showing income vs expense breakdown
- **Transaction Management** – Full CRUD (Create, Read, Update, Delete)
- **Category System** – Income: Gaji, Investasi, Bonus | Expense: Makanan, Transport, Belanja, Hiburan, Kesehatan, Pendidikan, Tagihan
- **Category Icons** – Each transaction displays a relevant icon
- **Filter Tabs** – View All, Income-only, or Expense-only transactions
- **Optional Notes** – Add notes to each transaction
- **Logout** – Session clearing with confirmation

## Tech Stack

- Flutter & Dart
- SQLite via `sqflite` (persistent local database)
- SharedPreferences (session management)
- `intl` (Rupiah currency formatting)
- `uuid` (unique transaction IDs)
- `fl_chart` (donut chart visualization)
- Object-Oriented Programming (OOP) architecture

## Demo Credentials

| Username | Password  |
|----------|-----------|
| admin    | admin123  |

## Project Structure

lib/
├── main.dart
├── theme/app_theme.dart
├── models/transaction.dart
├── services/
│   ├── auth_service.dart
│   └── database_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   └── home_screen.dart
└── widgets/
├── custom_button.dart
├── custom_text_field.dart
├── transaction_card.dart
└── donut_chart.dart

## Getting Started

```bash
git clone https://github.com/bethaniapermai/budgeting-tracker
cd budgeting_tracker
flutter pub get
flutter run
```

## Author

**Bethania Permai Simangunsong**  
D4 Software Engineering Technology — Institut Teknologi Del  
[github.com/bethaniapermai](https://github.com/bethaniapermai)
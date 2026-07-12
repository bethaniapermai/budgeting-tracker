import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/transaction.dart' as model;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static sqflite.Database? _database;

  DatabaseService._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budgeting.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);
    return await sqflite.openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        isIncome INTEGER NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<model.Transaction> create(model.Transaction tx) async {
    final db = await database;
    final id = await db.insert('transactions', tx.toMap());
    return tx.copyWith(id: id);
  }

  Future<List<model.Transaction>> getAll() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => model.Transaction.fromMap(e)).toList();
  }

  Future<List<model.Transaction>> getByMonth(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 0, 23, 59).toIso8601String();
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return result.map((e) => model.Transaction.fromMap(e)).toList();
  }

  Future<int> update(model.Transaction tx) async {
    final db = await database;
    return await db.update('transactions', tx.toMap(),
        where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    final txs = await getByMonth(year, month);
    double income = 0, expense = 0;
    for (final tx in txs) {
      if (tx.isIncome) income += tx.amount;
      else expense += tx.amount;
    }
    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  Future<Map<String, double>> getCategoryTotals(bool isIncome) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE isIncome = ?
      GROUP BY category
    ''', [isIncome ? 1 : 0]);
    return {
      for (var r in result)
        r['category'] as String: (r['total'] as num).toDouble()
    };
  }
}
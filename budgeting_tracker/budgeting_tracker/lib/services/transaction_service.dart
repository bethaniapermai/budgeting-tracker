import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionService {
  static const _key = 'transactions';

  static Future<List<Transaction>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((e) => Transaction.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> add(Transaction tx) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(tx.toMap()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.removeWhere((e) {
      final map = jsonDecode(e);
      return map['id'] == id;
    });
    await prefs.setStringList(_key, data);
  }

  static Future<void> update(Transaction updated) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    final index = data.indexWhere((e) {
      final map = jsonDecode(e);
      return map['id'] == updated.id;
    });
    if (index != -1) {
      data[index] = jsonEncode(updated.toMap());
      await prefs.setStringList(_key, data);
    }
  }
}
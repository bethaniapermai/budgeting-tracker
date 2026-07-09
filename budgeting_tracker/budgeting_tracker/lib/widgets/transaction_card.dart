import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppTheme.income : AppTheme.expense;
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 3),
                  Text(
                      '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit,
                          size: 16, color: AppTheme.textLight),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete,
                          size: 16, color: AppTheme.expense),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
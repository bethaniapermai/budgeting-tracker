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

  IconData get _categoryIcon {
    switch (transaction.category) {
      case 'Gaji': return Icons.work_rounded;
      case 'Makanan': return Icons.restaurant_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Belanja': return Icons.shopping_bag_rounded;
      case 'Hiburan': return Icons.movie_rounded;
      case 'Kesehatan': return Icons.local_hospital_rounded;
      case 'Pendidikan': return Icons.school_rounded;
      case 'Investasi': return Icons.trending_up_rounded;
      case 'Tagihan': return Icons.receipt_rounded;
      default: return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppTheme.income : AppTheme.expense;
    final bgColor = isIncome
        ? AppTheme.income.withValues(alpha: 0.1)
        : AppTheme.expense.withValues(alpha: 0.1);
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_categoryIcon, color: color, size: 22),
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
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(transaction.note!,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13, color: color),
              ),
              const SizedBox(height: 6),
              Row(children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 14, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        size: 14, color: AppTheme.expense),
                  ),
                ),
              ]),
            ],
          ),
        ]),
      ),
    );
  }
}
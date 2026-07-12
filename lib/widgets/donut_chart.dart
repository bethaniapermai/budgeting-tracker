import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DonutChart extends StatefulWidget {
  final double income;
  final double expense;

  const DonutChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.income + widget.expense;
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Bulan Ini',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          total == 0
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Belum ada transaksi bulan ini',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                    ),
                  ),
                )
              : Row(children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 42,
                        sections: [
                          PieChartSectionData(
                            color: AppTheme.income,
                            value: widget.income,
                            title:
                                '${(widget.income / total * 100).toStringAsFixed(0)}%',
                            radius: _touchedIndex == 0 ? 34 : 26,
                            titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: AppTheme.expense,
                            value: widget.expense,
                            title:
                                '${(widget.expense / total * 100).toStringAsFixed(0)}%',
                            radius: _touchedIndex == 1 ? 34 : 26,
                            titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendItem(
                            Icons.arrow_downward_rounded,
                            'Pemasukan',
                            formatter.format(widget.income),
                            AppTheme.income),
                        const SizedBox(height: 12),
                        _legendItem(
                            Icons.arrow_upward_rounded,
                            'Pengeluaran',
                            formatter.format(widget.expense),
                            AppTheme.expense),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1),
                        ),
                        _legendItem(
                            Icons.account_balance_wallet_rounded,
                            'Saldo',
                            formatter.format(widget.income - widget.expense),
                            widget.income >= widget.expense
                                ? AppTheme.income
                                : AppTheme.expense),
                      ],
                    ),
                  ),
                ]),
        ],
      ),
    );
  }

  Widget _legendItem(
      IconData icon, String label, String amount, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppTheme.textLight)),
        Text(amount,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color)),
      ]),
    ]);
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/transaction_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _username = '';
  int _selectedTab = 0; // 0=All, 1=Income, 2=Expense

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txs = await TransactionService.getAll();
    final name = await AuthService.getUsername();
    setState(() {
      _transactions = txs;
      _username = name;
      _isLoading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  List<Transaction> get _filtered {
    if (_selectedTab == 1) return _transactions.where((t) => t.isIncome).toList();
    if (_selectedTab == 2) return _transactions.where((t) => !t.isIncome).toList();
    return _transactions;
  }

  void _showForm({Transaction? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
        text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    bool isIncome = existing?.isIncome ?? true;
    String category = existing?.category ?? 'Lainnya';
    final formKey = GlobalKey<FormState>();

    final categories = [
      'Gaji', 'Makanan', 'Transport', 'Belanja',
      'Hiburan', 'Kesehatan', 'Pendidikan', 'Lainnya'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  existing != null ? 'Edit Transaksi' : 'Tambah Transaksi',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      color: AppTheme.textDark),
                ),
                const SizedBox(height: 20),
                // Toggle Income/Expense
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModal(() => isIncome = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isIncome
                              ? AppTheme.income
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward,
                                color: isIncome
                                    ? Colors.white
                                    : AppTheme.textLight,
                                size: 16),
                            const SizedBox(width: 6),
                            Text('Pemasukan',
                                style: TextStyle(
                                    color: isIncome
                                        ? Colors.white
                                        : AppTheme.textLight,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModal(() => isIncome = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isIncome
                              ? AppTheme.expense
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward,
                                color: !isIncome
                                    ? Colors.white
                                    : AppTheme.textLight,
                                size: 16),
                            const SizedBox(width: 6),
                            Text('Pengeluaran',
                                style: TextStyle(
                                    color: !isIncome
                                        ? Colors.white
                                        : AppTheme.textLight,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Judul Transaksi',
                  hint: 'cth: Gaji Januari',
                  prefixIcon: Icons.notes,
                  controller: titleCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Jumlah (Rp)',
                  hint: 'cth: 500000',
                  prefixIcon: Icons.payments_outlined,
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                    if (double.tryParse(v) == null) return 'Masukkan angka valid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                // Category dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kategori',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setModal(() => category = v ?? 'Lainnya'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: existing != null
                      ? 'Simpan Perubahan'
                      : 'Tambah Transaksi',
                  fullWidth: true,
                  icon: existing != null ? Icons.save : Icons.add,
                  color: isIncome ? AppTheme.income : AppTheme.expense,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final tx = Transaction(
                      id: existing?.id ?? const Uuid().v4(),
                      title: titleCtrl.text.trim(),
                      amount: double.parse(amountCtrl.text),
                      isIncome: isIncome,
                      date: existing?.date ?? DateTime.now(),
                      category: category,
                    );
                    if (existing != null) {
                      await TransactionService.update(tx);
                    } else {
                      await TransactionService.add(tx);
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                    _load();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await TransactionService.delete(id);
      _load();
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $_username 👋'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Saldo',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(formatter.format(_balance),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(children: [
                                    Icon(Icons.arrow_downward,
                                        color: Colors.greenAccent, size: 14),
                                    SizedBox(width: 4),
                                    Text('Pemasukan',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ]),
                                  const SizedBox(height: 2),
                                  Text(formatter.format(_totalIncome),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(children: [
                                    Icon(Icons.arrow_upward,
                                        color: Colors.redAccent, size: 14),
                                    SizedBox(width: 4),
                                    Text('Pengeluaran',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ]),
                                  const SizedBox(height: 2),
                                  Text(formatter.format(_totalExpense),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Filter tabs
                    Row(children: [
                      _tab('Semua', 0),
                      const SizedBox(width: 8),
                      _tab('Pemasukan', 1),
                      const SizedBox(width: 8),
                      _tab('Pengeluaran', 2),
                    ]),
                    const SizedBox(height: 16),
                    // Transaction list
                    if (_filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(children: [
                            Icon(Icons.receipt_long,
                                size: 56,
                                color: AppTheme.textLight.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            const Text('Belum ada transaksi',
                                style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            const Text(
                                'Tap tombol + untuk menambahkan',
                                style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 12)),
                          ]),
                        ),
                      )
                    else
                      ...(_filtered.map((tx) => TransactionCard(
                            transaction: tx,
                            onDelete: () => _delete(tx.id),
                            onEdit: () => _showForm(existing: tx),
                          ))),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textLight)),
      ),
    );
  }
}
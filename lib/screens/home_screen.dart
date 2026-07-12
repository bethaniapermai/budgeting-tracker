import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/transaction_card.dart';
import 'login_screen.dart';
import '../widgets/donut_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _username = '';
  int _selectedTab = 0;
  late TabController _tabController;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, double> _summary = {'income': 0, 'expense': 0, 'balance': 0};
  int _touchedDonutIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final txs = await DatabaseService.instance
        .getByMonth(_selectedMonth.year, _selectedMonth.month);
    final summary = await DatabaseService.instance
        .getMonthlySummary(_selectedMonth.year, _selectedMonth.month);
    final name = await AuthService.getUsername();
    if (!mounted) return;
    setState(() {
      _transactions = txs;
      _summary = summary;
      _username = name;
      _isLoading = false;
    });
  }

  List<Transaction> get _filtered {
    if (_selectedTab == 1) return _transactions.where((t) => t.isIncome).toList();
    if (_selectedTab == 2) return _transactions.where((t) => !t.isIncome).toList();
    return _transactions;
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  void _changeMonth(int delta) {
    if (delta > 0 && _isCurrentMonth) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
    _load();
  }

  void _showForm({Transaction? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
        text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    bool isIncome = existing?.isIncome ?? true;
    String category = existing?.category ?? 'Lainnya';
    final formKey = GlobalKey<FormState>();

    final incomeCategories = ['Gaji', 'Investasi', 'Bonus', 'Lainnya'];
    final expenseCategories = [
      'Makanan', 'Transport', 'Belanja', 'Hiburan',
      'Kesehatan', 'Pendidikan', 'Tagihan', 'Lainnya'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          final categories = isIncome ? incomeCategories : expenseCategories;
          if (!categories.contains(category)) category = 'Lainnya';

          return Container(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      existing != null ? 'Edit Transaksi' : 'Tambah Transaksi',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModal(() => isIncome = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isIncome ? AppTheme.income : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_downward_rounded,
                                      color: isIncome ? Colors.white : AppTheme.textLight,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Text('Pemasukan',
                                      style: TextStyle(
                                          color: isIncome ? Colors.white : AppTheme.textLight,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModal(() => isIncome = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isIncome ? AppTheme.expense : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_upward_rounded,
                                      color: !isIncome ? Colors.white : AppTheme.textLight,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Text('Pengeluaran',
                                      style: TextStyle(
                                          color: !isIncome ? Colors.white : AppTheme.textLight,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Judul',
                      hint: 'cth: Gaji Juli',
                      prefixIcon: Icons.notes_rounded,
                      controller: titleCtrl,
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Jumlah (Rp)',
                      hint: 'cth: 500000',
                      prefixIcon: Icons.payments_rounded,
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(v) == null) return 'Angka tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Kategori',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final selected = category == cat;
                        return GestureDetector(
                          onTap: () => setModal(() => category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? (isIncome ? AppTheme.income : AppTheme.primary)
                                  : AppTheme.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(cat,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : AppTheme.primary)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Catatan (opsional)',
                      hint: 'Tambahkan catatan...',
                      prefixIcon: Icons.edit_note_rounded,
                      controller: noteCtrl,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final tx = Transaction(
                            id: existing?.id,
                            title: titleCtrl.text.trim(),
                            amount: double.parse(amountCtrl.text),
                            isIncome: isIncome,
                            date: existing?.date ?? DateTime.now(),
                            category: category,
                            note: noteCtrl.text.trim().isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                          );
                          if (existing != null) {
                            await DatabaseService.instance.update(tx);
                          } else {
                            await DatabaseService.instance.create(tx);
                          }
                          if (!mounted) return;
                          Navigator.pop(context);
                          _load();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isIncome ? AppTheme.income : AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          existing != null ? 'Simpan Perubahan' : 'Tambah Transaksi',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.expense,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseService.instance.delete(id);
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
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 230,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.primary,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      onPressed: _logout,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.account_balance_wallet_rounded,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text('Halo, $_username!',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ]),
                              const SizedBox(height: 6),
                              // Month selector
                              Row(children: [
                                GestureDetector(
                                  onTap: () => _changeMonth(-1),
                                  child: const Icon(Icons.chevron_left,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMMM yyyy').format(_selectedMonth),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _changeMonth(1),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: _isCurrentMonth
                                        ? Colors.white30
                                        : Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Text(
                                formatter.format(_summary['balance']!),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text('Total Saldo',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(children: [
                                      const Icon(Icons.arrow_downward_rounded,
                                          color: Colors.greenAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Pemasukan',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 9)),
                                            Text(
                                              formatter.format(_summary['income']!),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(children: [
                                      const Icon(Icons.arrow_upward_rounded,
                                          color: Colors.redAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Pengeluaran',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 9)),
                                            Text(
                                              formatter.format(_summary['expense']!),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Pemasukan'),
                      Tab(text: 'Pengeluaran'),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Transaction list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: _filtered.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_rounded,
                                      size: 56,
                                      color: AppTheme.textLight.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  const Text('Belum ada transaksi',
                                      style: TextStyle(
                                          color: AppTheme.textLight, fontSize: 15)),
                                  const SizedBox(height: 6),
                                  const Text('Tap + untuk menambahkan',
                                      style: TextStyle(
                                          color: AppTheme.textLight, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => TransactionCard(
                              transaction: _filtered[i],
                              onDelete: () => _delete(_filtered[i].id!),
                              onEdit: () => _showForm(existing: _filtered[i]),
                            ),
                            childCount: _filtered.length,
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
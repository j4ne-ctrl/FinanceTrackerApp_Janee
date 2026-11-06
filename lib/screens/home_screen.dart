import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/categories.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomeScreen({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return TxStreamBuilder(
      builder: (context, list) {
        final income = list
            .where((t) => t.type == TxType.income)
            .fold<int>(0, (s, t) => s + t.amount);
        final expense = list
            .where((t) => t.type == TxType.expense)
            .fold<int>(0, (s, t) => s + t.amount);
        final incomeCount = list.where((t) => t.isIncome).length;
        final expenseCount = list.length - incomeCount;
        final recent = list.take(6).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          children: [
            _Header(),
            const SizedBox(height: 22),
            _BalanceCard(balance: income - expense, income: income, expense: expense),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.swap_vert_rounded,
                    color: AppColors.primaryDark,
                    value: '${list.length}',
                    label: 'Total transaksi',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.south_west_rounded,
                    color: AppColors.income,
                    value: '$incomeCount',
                    label: 'Pemasukan',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Icons.north_east_rounded,
                    color: AppColors.expense,
                    value: '$expenseCount',
                    label: 'Pengeluaran',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Riwayat Transaksi',
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text('Lihat semua',
                      style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'Belum ada transaksi',
                subtitle:
                    'Tekan tombol + di bawah untuk mencatat transaksi pertamamu.',
              )
            else
              ...recent.map((t) => TransactionTile(tx: t)),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UserProfileBuilder(
      builder: (context, p) => Row(
        children: [
          UserAvatar.fromProfile(p, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting(),
                    style: GoogleFonts.poppins(
                        fontSize: 12.5, color: AppColors.muted)),
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
              ],
            ),
          ),
          CircleIconButton(
            icon: Icons.logout_rounded,
            onTap: () => confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;
  final int income;
  final int expense;
  const _BalanceCard(
      {required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.glossColors,
              ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppColors.primaryDark, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('Total Saldo',
                        style: GoogleFonts.poppins(
                            color: AppColors.muted,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          balance < 0 ? '-Rp' : 'Rp',
                          style: GoogleFonts.poppins(
                              color: AppColors.muted,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        plainNumber(balance.abs()),
                        style: GoogleFonts.poppins(
                            color: AppColors.ink,
                            fontSize: 40,
                            height: 1.15,
                            letterSpacing: -0.8,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MiniFlow(
                        icon: Icons.south_west_rounded,
                        label: 'Pemasukan',
                        color: AppColors.income,
                        value: rupiah(income),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniFlow(
                        icon: Icons.north_east_rounded,
                        label: 'Pengeluaran',
                        color: AppColors.expense,
                        value: rupiah(expense),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniFlow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MiniFlow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.glossColors,
        ),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.85), width: 1.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        color: AppColors.muted,
                        fontSize: 10.5)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatTile(
      {required this.icon,
      required this.color,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.glossColors,
        ),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.8), width: 1.2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w700, height: 1)),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.muted)),
        ],
      ),
    );
  }
}
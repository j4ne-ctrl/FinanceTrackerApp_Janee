import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/categories.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  bool get _isCurrentMonth {
    final n = DateTime.now();
    return _month.year == n.year && _month.month == n.month;
  }

  @override
  Widget build(BuildContext context) {
    return TxStreamBuilder(
      builder: (context, list) {
        bool inMonth(TransactionModel t, DateTime m) =>
            t.date.year == m.year && t.date.month == m.month;

        int sumOf(DateTime m, TxType type) => list
            .where((t) => t.type == type && inMonth(t, m))
            .fold<int>(0, (s, t) => s + t.amount);

        final spent = sumOf(_month, TxType.expense);
        final earned = sumOf(_month, TxType.income);
        final prevSpent =
            sumOf(DateTime(_month.year, _month.month - 1), TxType.expense);

        final months =
            List.generate(6, (i) => DateTime(_month.year, _month.month - 5 + i));
        final values = months.map((m) => sumOf(m, TxType.expense)).toList();
        var maxV = values.reduce((a, b) => a > b ? a : b);
        if (maxV == 0) maxV = 1;

        final byCat = <String, int>{};
        for (final t in list) {
          if (t.type == TxType.expense && inMonth(t, _month)) {
            byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
          }
        }
        final cats = byCat.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        String changeText;
        if (prevSpent == 0) {
          changeText = 'Belum ada data bulan sebelumnya';
        } else {
          final pct = ((spent - prevSpent) / prevSpent * 100).abs();
          changeText =
              '${pct.toStringAsFixed(1)}% ${spent <= prevSpent ? 'lebih rendah' : 'lebih tinggi'} dari bulan lalu';
        }

        final net = earned - spent;
        String summary;
        if (earned == 0 && spent == 0) {
          summary = 'Belum ada transaksi di bulan ini.';
        } else if (net >= 0) {
          summary = 'Kamu berhasil menyisihkan ${rupiah(net)} bulan ini.';
        } else {
          summary = 'Pengeluaran melebihi pemasukan sebesar ${rupiah(-net)}.';
        }

        final topText = cats.isEmpty
            ? 'Belum ada pengeluaran bulan ini.'
            : '${cats.first.key} menyumbang ${(cats.first.value / spent * 100).round()}% dari total pengeluaran.';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
          children: [
            Text('Statistik',
                style: GoogleFonts.poppins(
                    fontSize: 26, fontWeight: FontWeight.w700)),
            Text('Pahami ke mana uangmu pergi.',
                style:
                    GoogleFonts.poppins(fontSize: 12.5, color: AppColors.muted)),
            const SizedBox(height: 16),

            // Pemilih bulan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => setState(() =>
                      _month = DateTime(_month.year, _month.month - 1)),
                ),
                Text(bulanTahun(_month),
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Opacity(
                  opacity: _isCurrentMonth ? 0.35 : 1,
                  child: CircleIconButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      if (_isCurrentMonth) return;
                      setState(() =>
                          _month = DateTime(_month.year, _month.month + 1));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Kartu ringkasan
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
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
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total pengeluaran',
                      style: GoogleFonts.poppins(
                          color: AppColors.muted,
                          fontSize: 12.5)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(rupiah(spent),
                        style: GoogleFonts.poppins(
                            color: AppColors.ink,
                            fontSize: 32,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        spent <= prevSpent
                            ? Icons.trending_down_rounded
                            : Icons.trending_up_rounded,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(changeText,
                            style: GoogleFonts.poppins(
                                color: AppColors.ink, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tren pengeluaran 6 bulan
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.glossColors,
                ),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8), width: 1.2),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tren pengeluaran',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('6 bulan terakhir • ketuk batang untuk memilih bulan',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(6, (i) {
                        final selected = i == 5;
                        final h = 8 + 96 * (values[i] / maxV);
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _month = months[i]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (selected)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.ink,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(compact(values[i]),
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                  width: 28,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.primary
                                            .withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(bulanSingkat(months[i]),
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: selected
                                            ? AppColors.ink
                                            : AppColors.muted)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kategori teratas
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.glossColors,
                ),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8), width: 1.2),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori teratas',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (cats.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Belum ada pengeluaran di bulan ini.',
                          style: GoogleFonts.poppins(
                              fontSize: 12.5, color: AppColors.muted)),
                    )
                  else
                    ...cats.take(5).map((e) {
                      final cat = Categories.find(e.key, TxType.expense);
                      final frac = spent == 0 ? 0.0 : e.value / spent;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(cat.icon, size: 18, color: cat.color),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(e.key,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Text('${(frac * 100).round()}%',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        color: AppColors.muted)),
                                const SizedBox(width: 10),
                                Text(rupiah(e.value),
                                    style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 7),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: frac,
                                minHeight: 6,
                                backgroundColor:
                                    cat.color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation(cat.color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Insight
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _InsightCard(
                      color: const Color(0xFFD8ECFD),
                      icon: Icons.auto_awesome_rounded,
                      title: 'Ringkasan',
                      text: summary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InsightCard(
                      color: const Color(0xFFFDEFD6),
                      icon: Icons.lightbulb_rounded,
                      title: 'Perlu dicatat',
                      text: topText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String text;
  const _InsightCard(
      {required this.color,
      required this.icon,
      required this.title,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w500, height: 1.4)),
        ],
      ),
    );
  }
}

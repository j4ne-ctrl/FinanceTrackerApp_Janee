import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  int _filter = 0; // 0 semua, 1 pemasukan, 2 pengeluaran

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Riwayat Transaksi',
                  style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.w700)),
              Text('Semua catatan, diurutkan dari yang terbaru.',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, color: AppColors.muted)),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Cari transaksi...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _chip('Semua', 0),
                  const SizedBox(width: 8),
                  _chip('Pemasukan', 1),
                  const SizedBox(width: 8),
                  _chip('Pengeluaran', 2),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Expanded(
          child: TxStreamBuilder(
            builder: (context, list) {
              final filtered = list.where((t) {
                if (_filter == 1 && !t.isIncome) return false;
                if (_filter == 2 && t.isIncome) return false;
                if (_query.isEmpty) return true;
                return t.title.toLowerCase().contains(_query) ||
                    t.category.toLowerCase().contains(_query) ||
                    t.note.toLowerCase().contains(_query);
              }).toList();

              if (filtered.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  children: [
                    EmptyState(
                      icon: Icons.search_off_rounded,
                      title: list.isEmpty
                          ? 'Belum ada transaksi'
                          : 'Tidak ada hasil',
                      subtitle: list.isEmpty
                          ? 'Catat transaksi pertamamu dengan tombol +.'
                          : 'Coba kata kunci atau filter yang lain.',
                    ),
                  ],
                );
              }

              // Total bersih per hari (pemasukan - pengeluaran)
              final net = <DateTime, int>{};
              for (final t in filtered) {
                final d = DateUtils.dateOnly(t.date);
                net[d] = (net[d] ?? 0) + (t.isIncome ? t.amount : -t.amount);
              }

              final children = <Widget>[];
              DateTime? last;
              for (final t in filtered) {
                final d = DateUtils.dateOnly(t.date);
                if (last == null || d != last) {
                  final n = net[d] ?? 0;
                  children.add(Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dayLabel(t.date),
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted)),
                        Text('${n >= 0 ? '+' : '-'}${rupiah(n.abs())}',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted)),
                      ],
                    ),
                  ));
                  last = d;
                }
                children.add(TransactionTile(tx: t));
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                children: children,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, int value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.ink,
      backgroundColor: Colors.white.withValues(alpha: 0.6),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
      shape: const StadiumBorder(),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppColors.ink,
      ),
    );
  }
}

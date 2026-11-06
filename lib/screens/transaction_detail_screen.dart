import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/categories.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String id;
  const TransactionDetailScreen({super.key, required this.id});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late final Stream<TransactionModel?> _stream =
      FirestoreService.instance.streamTransaction(widget.id);
  bool _deleting = false;

  Future<void> _delete(TransactionModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.expense.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: AppColors.expense),
        ),
        title: Text('Hapus transaksi?',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text(
          '"${t.title}" akan dihapus permanen dari Cloud Firestore dan tidak bisa dikembalikan.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _deleting = true);
    try {
      // Delete itu idempotent, jadi aman dicoba lagi kalau timeout.
      await FirestoreService.instance
          .delete(t.id)
          .timeout(const Duration(seconds: 3));
      messenger.showSnackBar(appSnack('Transaksi dihapus'));
      nav.pop();
    } on TimeoutException {
      messenger.showSnackBar(appSnack(
          'Belum terkonfirmasi server. Periksa koneksi lalu coba hapus lagi.',
          error: true));
      if (mounted) setState(() => _deleting = false);
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
          appSnack('Gagal menghapus [${e.code}]: ${e.message}', error: true));
      if (mounted) setState(() => _deleting = false);
    } catch (e) {
      messenger.showSnackBar(appSnack('Gagal menghapus: $e', error: true));
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: StreamBuilder<TransactionModel?>(
            stream: _stream,
            builder: (context, snap) {
              if (_deleting ||
                  (snap.connectionState == ConnectionState.waiting &&
                      !snap.hasData)) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              final t = snap.data;
              if (t == null) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                        child: CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Transaksi tidak ditemukan',
                          subtitle: 'Data ini mungkin sudah dihapus.',
                        ),
                      ),
                    ),
                  ],
                );
              }
              return _buildContent(t);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TransactionModel t) {
    final cat = Categories.find(t.category, t.type);
    final accent = t.isIncome ? AppColors.income : AppColors.expense;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text('Detail Transaksi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              CircleIconButton(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColors.expense,
                onTap: () => _delete(t),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              // Kartu nominal
              Container(
                padding: const EdgeInsets.all(24),
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
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
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
                      child: Icon(cat.icon, color: cat.color, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(t.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: AppColors.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${t.isIncome ? '+' : '-'}${rupiah(t.amount)}',
                        style: GoogleFonts.poppins(
                            color: accent,
                            fontSize: 34,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.glossColors,
                        ),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8), width: 1.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t.isIncome ? 'Pemasukan' : 'Pengeluaran',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rincian
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  children: [
                    _row(Icons.title_rounded, 'Judul', t.title),
                    _divider(),
                    _row(cat.icon, 'Kategori', t.category, iconColor: cat.color),
                    _divider(),
                    _row(Icons.event_rounded, 'Tanggal', tanggalJam(t.date)),
                    _divider(),
                    _row(Icons.sticky_note_2_outlined, 'Catatan',
                        t.note.isEmpty ? 'Tidak ada catatan' : t.note,
                        muted: t.note.isEmpty),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              PrimaryButton(
                label: 'Edit Transaksi',
                icon: Icons.edit_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => AddTransactionScreen(transaction: t),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _delete(t),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text('Hapus Transaksi',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.expense,
                    side: const BorderSide(color: AppColors.expense, width: 1.4),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: AppColors.muted.withValues(alpha: 0.15));

  Widget _row(IconData icon, String label, String value,
      {Color? iconColor, bool muted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? AppColors.muted),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: muted ? AppColors.muted : AppColors.ink)),
          ),
        ],
      ),
    );
  }
}
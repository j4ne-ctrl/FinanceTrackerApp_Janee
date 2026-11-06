import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/categories.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// Dipakai untuk TAMBAH transaksi (transaction == null) dan EDIT transaksi.
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  TxType _type = TxType.expense;
  String _category = Categories.expense.first.name;
  DateTime _date = DateTime.now();
  bool _saving = false;
  // ID tetap selama layar ini terbuka -> coba simpan ulang tidak membuat data ganda.
  late final String _newId = FirestoreService.instance.newId();

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _title.text = t.title;
      _amount.text = plainNumber(t.amount);
      _note.text = t.note;
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _setType(TxType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      final names = Categories.of(type).map((c) => c.name);
      if (!names.contains(_category)) _category = Categories.of(type).first.name;
    });
  }

  /// Menambah nominal lewat tombol pilihan cepat.
  void _addAmount(int v) {
    final next = parseAmount(_amount.text) + v;
    if (next > 999999999999) return;
    setState(() => _amount.text = plainNumber(next));
  }

  Widget _quickChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day,
          _date.hour, _date.minute));
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _saving = true);

    final tx = TransactionModel(
      id: widget.transaction?.id ?? _newId,
      title: _title.text.trim(),
      amount: parseAmount(_amount.text),
      type: _type,
      category: _category,
      note: _note.text.trim(),
      date: _date,
    );

    try {
      final Future<void> op = _isEdit
          ? FirestoreService.instance.update(tx)
          : FirestoreService.instance.add(tx);
      // Future Firestore baru selesai setelah SERVER mengonfirmasi. Kalau
      // timeout, JANGAN dianggap berhasil: di web tidak ada cache lokal, jadi
      // data yang belum terkonfirmasi akan hilang saat halaman di-refresh.
      await op.timeout(const Duration(seconds: 10));
      messenger.showSnackBar(appSnack(
          _isEdit ? 'Transaksi diperbarui' : 'Transaksi berhasil ditambahkan'));
      nav.pop();
    } on TimeoutException {
      messenger.showSnackBar(appSnack(
          'Belum terkonfirmasi server. Periksa koneksi lalu tekan Simpan lagi.',
          error: true));
      if (mounted) setState(() => _saving = false);
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
          appSnack('Gagal menyimpan [${e.code}]: ${e.message}', error: true));
      if (mounted) setState(() => _saving = false);
    } catch (e) {
      messenger.showSnackBar(appSnack('Gagal menyimpan: $e', error: true));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TxType.income;
    final accent = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 46),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      // Toggle tipe
                      Container(
                        padding: const EdgeInsets.all(5),
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
                        child: Row(
                          children: [
                            _typeButton('Pengeluaran', TxType.expense,
                                Icons.north_east_rounded, AppColors.expense),
                            _typeButton('Pemasukan', TxType.income,
                                Icons.south_west_rounded, AppColors.income),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Nominal
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                            Text('Nominal',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: AppColors.muted)),
                            TextFormField(
                              controller: _amount,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                ThousandsFormatter(),
                              ],
                              style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: accent),
                              decoration: InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                prefixText: 'Rp ',
                                prefixStyle: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: accent),
                                hintText: '0',
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted
                                        .withValues(alpha: 0.4)),
                              ),
                              validator: (v) => parseAmount(v ?? '') <= 0
                                  ? 'Nominal harus lebih dari 0'
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final v in const [
                                  10000,
                                  20000,
                                  50000,
                                  100000,
                                  500000,
                                ])
                                  _quickChip(
                                      '+${compact(v)}', accent, () => _addAmount(v)),
                                _quickChip('Hapus', AppColors.muted,
                                    () => setState(() => _amount.clear())),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      AppField(
                        controller: _title,
                        label: 'Judul transaksi',
                        icon: Icons.edit_note_rounded,
                        hint: isIncome ? 'mis. Gaji bulanan' : 'mis. Makan siang',
                        action: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Judul wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      Text('Kategori',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Categories.of(_type).map((c) {
                          final selected = c.name == _category;
                          return GestureDetector(
                            onTap: () => setState(() => _category = c.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: selected ? c.color : Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(c.icon,
                                      size: 16,
                                      color:
                                          selected ? Colors.white : c.color),
                                  const SizedBox(width: 6),
                                  Text(c.name,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : AppColors.ink)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Tanggal
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.glossColors,
                            ),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8), width: 1.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 19, color: AppColors.muted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(tanggal(_date),
                                    style: GoogleFonts.poppins(fontSize: 14)),
                              ),
                              const Icon(Icons.expand_more_rounded,
                                  color: AppColors.muted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      AppField(
                        controller: _note,
                        label: 'Catatan (opsional)',
                        icon: Icons.sticky_note_2_outlined,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: _isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi',
                        icon: Icons.check_rounded,
                        loading: _saving,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String label, TxType type, IconData icon, Color color) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
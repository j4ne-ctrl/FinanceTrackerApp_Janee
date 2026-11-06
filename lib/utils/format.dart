import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _rp =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final NumberFormat _plain = NumberFormat.decimalPattern('id_ID');

String rupiah(num v) => _rp.format(v);
String plainNumber(num v) => _plain.format(v);

String tanggal(DateTime d) => DateFormat('d MMM yyyy', 'id_ID').format(d);
String tanggalJam(DateTime d) =>
    DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(d);
String tanggalPendek(DateTime d) => DateFormat('d MMM, HH:mm', 'id_ID').format(d);
String bulanTahun(DateTime d) => DateFormat('MMMM yyyy', 'id_ID').format(d);
String bulanSingkat(DateTime d) => DateFormat('MMM', 'id_ID').format(d);

String dayLabel(DateTime d) {
  final today = DateUtils.dateOnly(DateTime.now());
  final day = DateUtils.dateOnly(d);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(d);
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Selamat pagi,';
  if (h < 15) return 'Selamat siang,';
  if (h < 18) return 'Selamat sore,';
  return 'Selamat malam,';
}

String compact(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)} jt';
  if (v >= 1000) return '${(v / 1000).round()} rb';
  return '$v';
}

/// Memformat input angka menjadi 1.000.000 secara otomatis saat mengetik.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    if (digits.length > 12) digits = digits.substring(0, 12);
    final formatted = _plain.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

int parseAmount(String text) =>
    int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

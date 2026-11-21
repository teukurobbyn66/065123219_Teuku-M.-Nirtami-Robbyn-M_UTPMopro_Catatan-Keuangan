import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Fmt {
  static final _rp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static String rupiah(num v) => _rp.format(v);
  static String date(DateTime d) => DateFormat('d MMM yyyy', 'id_ID').format(d);
  static String dayHeader(DateTime d) => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
  static String month(DateTime d) => DateFormat('MMMM yyyy', 'id_ID').format(d);
  static String monthShort(DateTime d) => DateFormat('MMM', 'id_ID').format(d);
  static String monthKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  static String greeting([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

/// Memformat input angka menjadi pemisah ribuan gaya Indonesia (1.500.000).
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final f = NumberFormat.decimalPattern('id_ID').format(int.parse(digits));
    return TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length));
  }

  static double parse(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

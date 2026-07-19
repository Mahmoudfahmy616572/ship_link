import 'package:intl/intl.dart';

// مساعد لتنسيق التواريخ في لوحات الأدمن (إنجليزي/عربي حسب اللغة)
class AdminDateFormatter {
  static String format(String? iso, {String locale = 'en'}) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final fmt = DateFormat('dd MMM yyyy • HH:mm', locale);
    return fmt.format(dt);
  }

  static String formatDate(String? iso, {String locale = 'en'}) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy', locale).format(dt);
  }
}

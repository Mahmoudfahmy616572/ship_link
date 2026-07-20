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

  // تنسيق نسبي (منذ كام دقيقة/ساعة/يوم)
  static String formatRelative(String? iso, {String locale = 'en'}) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return locale == 'ar' ? 'دلوقتي' : 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}${locale == 'ar' ? ' د' : 'm'}';
    if (diff.inHours < 24) return '${diff.inHours}${locale == 'ar' ? ' س' : 'h'}';
    return '${diff.inDays}${locale == 'ar' ? ' ي' : 'd'}';
  }
}

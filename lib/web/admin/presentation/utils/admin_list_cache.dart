// كاش بسيط في الذاكرة لقوائم الأدمن (بيقلل طلبات الشبكة المكررة)
class AdminListCache {
  static final Map<String, _CacheEntry> _store = {};

  static List<Map<String, dynamic>>? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.time).inMinutes > 5) {
      _store.remove(key);
      return null;
    }
    return entry.data;
  }

  static void set(String key, List<Map<String, dynamic>> data) {
    _store[key] = _CacheEntry(data, DateTime.now());
  }

  static void clear() => _store.clear();
}

class _CacheEntry {
  final List<Map<String, dynamic>> data;
  final DateTime time;
  _CacheEntry(this.data, this.time);
}

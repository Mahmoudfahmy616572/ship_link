import 'package:flutter/foundation.dart';
import 'package:ship_link/config.dart';
import 'package:ship_link/services/web_cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

enum WebAuthStatus { uninitialized, unauthenticated, authenticated }

class AuthServiceWeb extends ChangeNotifier {
  WebAuthStatus _status = WebAuthStatus.uninitialized;
  User? _user;
  String? _error;

  WebAuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;

  final _webCache = WebCacheService();

  Future<void> initialize() async {
    final session = Supabase.instance.client.auth.currentSession;
    _user = Supabase.instance.client.auth.currentUser;
    _status = _user != null
        ? WebAuthStatus.authenticated
        : WebAuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      _user = response.user;
      if (_user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': _user!.id,
          'email': email,
          'name': name,
          'role': 'user',
        });
        _status = WebAuthStatus.authenticated;
      }
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      _status = _user != null
          ? WebAuthStatus.authenticated
          : WebAuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _status = WebAuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.toString(),
      );
    } catch (e) {
      _error = e.toString();
      _status = WebAuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    await _webCache.clear();
    _user = null;
    _status = WebAuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:3000/reset-password',
      );
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getFriendlyMessage(dynamic error, String Function(String) t) {
    if (error is AuthException) return _mapAuthException(error, t);
    if (error is PostgrestException) return _mapPostgrestException(error, t);
    if (error is StorageException) return _mapStorageException(error, t);
    return _mapGenericException(error, t);
  }

  static String _mapAuthException(AuthException e, String Function(String) t) {
    final code = e.message;
    final lower = code.toLowerCase();

    if (lower.contains('invalid login credentials') ||
        lower.contains('email or password is incorrect') ||
        lower.contains('invalid_credentials')) {
      return t('error_invalid_credentials');
    }
    if (lower.contains('user already registered') ||
        lower.contains('email already registered') ||
        lower.contains('already registered')) {
      return t('error_email_already_registered');
    }
    if (lower.contains('password should be at least 6 characters')) {
      return t('password_min_length');
    }
    if (lower.contains('password is too short')) {
      return t('password_min_length');
    }
    if (lower.contains('email not confirmed') ||
        lower.contains('email_not_confirmed')) {
      return t('error_email_not_confirmed');
    }
    if (lower.contains('phone already registered') ||
        lower.contains('phone_number already registered')) {
      return t('error_phone_already_registered');
    }
    if (lower.contains('invalid email') ||
        lower.contains('invalid email format') ||
        lower.contains('not a valid email')) {
      return t('error_invalid_email');
    }
    if (lower.contains('user not found') ||
        lower.contains('user_not_found')) {
      return t('error_user_not_found');
    }
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('429')) {
      return t('error_rate_limit');
    }
    if (lower.contains('expired') ||
        lower.contains('token expired') ||
        lower.contains('link expired')) {
      return t('error_link_expired');
    }
    if (lower.contains('network error') ||
        lower.contains('timeout') ||
        lower.contains('connection')) {
      return t('error_network');
    }
    if (lower.contains('new password should be different') ||
        lower.contains('same as old')) {
      return t('error_same_password');
    }
    if (lower.contains('weak password')) {
      return t('error_weak_password');
    }

    return t('error_unknown');
  }

  static String _mapPostgrestException(PostgrestException e, String Function(String) t) {
    final lower = (e.message ?? '').toLowerCase();

    if (lower.contains('duplicate key') ||
        lower.contains('unique constraint') ||
        lower.contains('already exists')) {
      return t('error_duplicate_entry');
    }
    if (lower.contains('foreign key constraint') ||
        lower.contains('does not exist')) {
      return t('error_not_found');
    }
    if (lower.contains('violates row-level security') ||
        lower.contains('permission denied') ||
        lower.contains('unauthorized')) {
      return t('error_permission_denied');
    }
    if (lower.contains('null value in column') ||
        lower.contains('not null')) {
      return t('error_required_field');
    }
    if (lower.contains('check constraint')) {
      return t('error_invalid_value');
    }

    return t('error_unknown');
  }

  static String _mapStorageException(StorageException e, String Function(String) t) {
    final lower = (e.message ?? '').toLowerCase();

    if (lower.contains('not found') || lower.contains('does not exist')) {
      return t('error_file_not_found');
    }
    if (lower.contains('permission denied') || lower.contains('unauthorized')) {
      return t('error_permission_denied');
    }
    if (lower.contains('too large') || lower.contains('exceeds')) {
      return t('error_file_too_large');
    }

    return t('error_unknown');
  }

  static String _mapGenericException(dynamic e, String Function(String) t) {
    if (e == null) return t('error_unknown');
    final lower = e.toString().toLowerCase();

    if (lower.contains('socketexception') ||
        lower.contains('handshakeexception') ||
        lower.contains('connection refused') ||
        lower.contains('no route to host') ||
        lower.contains('dns')) {
      return t('error_network');
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return t('error_timeout');
    }
    if (lower.contains('formatexception') || lower.contains('malformed')) {
      return t('error_invalid_data');
    }

    return t('error_unknown');
  }
}

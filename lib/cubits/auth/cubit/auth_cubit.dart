import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/services/cache_service.dart';
import 'package:ship_link/services/referral_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:gotrue/gotrue.dart' as gotrue;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(InitialState()) {
    _authSub = _supabase.auth.onAuthStateChange.listen(_onAuthStateChange);
  }

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);
  final _supabase = Supabase.instance.client;
  late final StreamSubscription<gotrue.AuthState> _authSub;
  bool _googleInProgress = false;

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }

  void _onAuthStateChange(gotrue.AuthState authState) {
    if (!_googleInProgress) return;
    _googleInProgress = false;

    final session = authState.session;
    final user = session?.user;
    if (user == null) {
      emit(ErrorState('Google sign-in failed'));
      return;
    }
    token = user.id;
    _handleUserSession(user);
  }

  Future<void> _handleUserSession(User user) async {
    try {
      final existing = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      if (existing == null) {
        await _profileUpsert(user.id,
            email: user.email ?? '',
            name: user.userMetadata?['full_name'] ?? user.email ?? '');
        emit(NewGoogleUser());
      } else {
        emit(SuccessState());
      }
    } catch (e) {
      print('AuthCubit._handleUserSession error: $e');
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _profileUpsert(
    String userId, {
    required String email,
    String? name,
    String? phone,
    String? referralCode,
  }) async {
    final data = <String, dynamic>{
      'id': userId,
      'email': email,
    };
    if (name != null) data['name'] = name;
    if (phone != null && phone.isNotEmpty) data['phone_number'] = phone;
    data['role'] = 'user';
    data['code'] = ReferralService().generateCode();
    if (referralCode != null && referralCode.isNotEmpty) {
      final referrer = await ReferralService().lookupByCode(referralCode);
      if (referrer != null) {
        data['referred_by'] = referrer['id'];
      }
    }
    await _supabase.from('profiles').upsert(data);
  }

  // ============================================
  // Email / Password auth
  // ============================================

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    emit(RegisterLoading());
    try {
      final metaData = <String, dynamic>{'full_name': name};
      if (phone != null && phone.isNotEmpty) metaData['phone'] = phone;
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metaData,
      );
      final user = response.user;
      if (user != null) {
        await _profileUpsert(user.id, email: email, name: name, phone: phone);
        token = user.id;
        emit(Registersuccess());
      } else if (response.session == null) {
        emit(Registerfaild('Email confirmation required. Check your inbox.'));
      } else {
        emit(Registerfaild('Registration failed'));
      }
    } catch (e) {
      print('AuthCubit.signUp error: $e');
      emit(Registerfaild(e.toString()));
    }
  }

  Future<void> signIN({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        token = user.id;
        emit(SignInSuccess());
      } else {
        emit(SignInFaild('Invalid email or password'));
      }
    } catch (e) {
      print('AuthCubit.signIN error: $e');
      emit(SignInFaild(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(SignOutLoading());
    await _supabase.auth.signOut();
    token = '';
    await CacheService().clear();
    emit(InitialState());
  }

  // ============================================
  // Google Sign-In (via Supabase OAuth)
  // ============================================

  Future<void> signInWithGoogle() async {
    emit(LoadingState());
    try {
      _googleInProgress = true;
      final launched = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://callback',
      );
      if (!launched) {
        _googleInProgress = false;
        emit(ErrorState('Could not launch browser for Google sign-in'));
      }
    } catch (e) {
      _googleInProgress = false;
      print('AuthCubit.signInWithGoogle error: $e');
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> completeRegistration({
    String? phone,
    double? lat,
    double? lng,
    String? address,
  }) async {
    emit(LoadingState());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        emit(ErrorState('Not authenticated'));
        return;
      }
      final updates = <String, dynamic>{
        'id': user.id,
        if (phone != null && phone.isNotEmpty) 'phone_number': phone,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        if (address != null) 'address': address,
      };
      await _supabase.from('profiles').upsert(updates);
      emit(SuccessState());
    } catch (e) {
      print('AuthCubit.completeRegistration error: $e');
      emit(ErrorState(e.toString()));
    }
  }

  // ============================================
  // Driver auth (email/password)
  // ============================================

  Future<void> signUpDriver({
    required String email,
    required String password,
    required String phoneNumber,
    required String name,
    required String vehicleType,
    required String vehicleNumber,
    required String state,
  }) async {
    emit(RegisterDriverLoading());
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'phone': phoneNumber, 'role': 'driver'},
      );
      final user = response.user;
      if (user != null) {
        await _supabase.from('drivers').upsert({
          'id': user.id,
          'email': email,
          'name': name,
          'phone_number': phoneNumber,
          'vehicle_type': vehicleType,
          'vehicle_number': vehicleNumber,
          'state': state,
        });
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'email': email,
          'name': name,
          'phone_number': phoneNumber,
          'role': 'driver',
        });
        token = user.id;
        emit(RegisterDriversuccess());
      } else {
        emit(RegisterDriverfaild());
      }
    } catch (e) {
      emit(RegisterDriverfaild());
    }
  }

  Future<void> signINDriver({required String email, required String password}) async {
    emit(SignInDriverLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        token = user.id;
        // Ensure a driver row exists (for old accounts not yet migrated)
        final existing = await _supabase
            .from('drivers')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
        if (existing == null) {
          await _supabase.from('drivers').upsert({
            'id': user.id,
            'email': email,
            'name': user.userMetadata?['full_name'] ?? email,
          });
        }
        // Ensure profiles entry exists
        final profileExists = await _supabase
            .from('profiles')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
        if (profileExists == null) {
          await _supabase.from('profiles').upsert({
            'id': user.id,
            'email': email,
            'name': user.userMetadata?['full_name'] ?? email,
            'role': 'driver',
          });
        }
        emit(SignInDriverSuccess());
      } else {
        emit(SignInDriverFaild());
      }
    } catch (e) {
      emit(SignInDriverFaild());
    }
  }

  Future<void> signOutDriver() async {
    await _supabase.auth.signOut();
    token = '';
    await CacheService().clear();
    emit(InitialState());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

export 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit(this._repository) : super(AdminAuthInitial());

  final AdminRepository _repository;

  static AdminAuthCubit get(context) => BlocProvider.of<AdminAuthCubit>(context);

  Future<void> signIn({required String email, required String password}) async {
    emit(AdminAuthLoading());
    final result = await _repository.signIn(email: email, password: password);
    result.fold(
      (failure) {
        // ignore: avoid_print
        print('DEBUG AUTH FAILURE = ${failure.errMessage}');
        if (!isClosed) emit(AdminAuthFailure(failure.errMessage));
      },
      (admin) {
        if (!isClosed) {
          // ignore: avoid_print
          print('DEBUG AUTH admin authenticated');
          emit(AdminAuthSuccess(admin));
        }
      },
    );
  }

  Future<void> signOut() async {
    emit(AdminAuthLoading());
    final result = await _repository.signOut();
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminAuthFailure(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminSignedOut());
      },
    );
  }

  // بنتأكد لو فيه أدمن متسجل قبل كده ونرجعه عشان ندخله اللوحة على طول
  Future<void> checkSession() async {
    emit(AdminAuthChecking());
    final result = await _repository.checkSession();
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminAuthInitial());
      },
      (admin) {
        if (!isClosed) {
          if (admin != null) {
            emit(AdminAuthRestored(admin));
          } else {
            emit(AdminAuthInitial());
          }
        }
      },
    );
  }

  bool isAdminLoggedIn() {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null && (state is AdminAuthSuccess || state is AdminAuthRestored);
  }

  // الصلاحيات الحالية للأدمن المسجل
  bool get isSuperAdmin => state.isSuperAdmin;
  bool get canManage => state.canManage;
  bool get isViewer => state.isViewer;
  bool get canViewOnly => state.canViewOnly;
  String get adminRole => state.adminRole;
}

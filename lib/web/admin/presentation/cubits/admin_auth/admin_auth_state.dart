abstract class AdminAuthState {}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthSuccess extends AdminAuthState {
  final Map<String, dynamic> admin;
  AdminAuthSuccess(this.admin);
}

class AdminAuthFailure extends AdminAuthState {
  final String message;
  AdminAuthFailure(this.message);
}

class AdminSignedOut extends AdminAuthState {}

// حالة استرجاع السيشن المحفوظ (refresh من غير ما يدخل باسورد تاني)
class AdminAuthRestored extends AdminAuthState {
  final Map<String, dynamic> admin;
  AdminAuthRestored(this.admin);
}

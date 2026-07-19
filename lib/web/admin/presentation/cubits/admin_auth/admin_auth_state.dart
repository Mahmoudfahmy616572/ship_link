abstract class AdminAuthState {}

// حالة بتدل إننا لسه بنتأكد من الـ session المحفوظ (ممنوع نحوّل للوجين فيها)
class AdminAuthChecking extends AdminAuthState {}

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

// ناخد الـ role من حالة الأدمن عشان نعرف صلاحياته
extension AdminAuthRole on AdminAuthState {
  Map<String, dynamic>? get adminData {
    if (this is AdminAuthSuccess) return (this as AdminAuthSuccess).admin;
    if (this is AdminAuthRestored) return (this as AdminAuthRestored).admin;
    return null;
  }

  String get adminRole => adminData?['role']?.toString() ?? '';

  // الصلاحيات: super_admin بس اللي يقدر يضيف/يعدل/يحذف
  bool get isSuperAdmin => adminRole == 'super_admin';
  bool get canManage => isSuperAdmin;
  // المشاهد يشوف بس من غير أي صلاحية كتابة
  bool get isViewer => adminRole == 'viewer';
  bool get canViewOnly => isViewer && !isSuperAdmin;
}

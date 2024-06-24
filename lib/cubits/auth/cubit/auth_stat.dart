abstract class AuthState {}

class InitialState extends AuthState {}
// ============SignUP==============

class RegisterLoading extends AuthState {}

class Registersuccess extends AuthState {}

class Registerfaild extends AuthState {}

// ==============signin=================
class SignInLoading extends AuthState {}

class SignInSuccess extends AuthState {}

class SignInFaild extends AuthState {}
// ==============signOut=================

class SignOutLoading extends AuthState {}

class SignOutSuccess extends AuthState {}

class SignOutFaild extends AuthState {}

// ==============signin Driver=================
class SignInDriverLoading extends AuthState {}

class SignInDriverSuccess extends AuthState {}

class SignInDriverFaild extends AuthState {}
// ============SignUP Driver==============

class RegisterDriverLoading extends AuthState {}

class RegisterDriversuccess extends AuthState {}

class RegisterDriverfaild extends AuthState {}

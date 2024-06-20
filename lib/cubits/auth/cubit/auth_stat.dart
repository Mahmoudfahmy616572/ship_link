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

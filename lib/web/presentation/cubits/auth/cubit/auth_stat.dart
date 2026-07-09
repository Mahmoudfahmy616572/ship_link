import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialState extends AuthState {}

class LoadingState extends AuthState {}

class SuccessState extends AuthState {}

class NewGoogleUser extends AuthState {}

class ErrorState extends AuthState {
  final String message;
  ErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class RegisterLoading extends AuthState {}

class Registersuccess extends AuthState {}

class Registerfaild extends AuthState {
  final String message;
  Registerfaild([this.message = '']);
  @override
  List<Object?> get props => [message];
}

class SignInLoading extends AuthState {}

class SignInSuccess extends AuthState {}

class SignInFaild extends AuthState {
  final String message;
  SignInFaild([this.message = '']);
  @override
  List<Object?> get props => [message];
}

class SignOutLoading extends AuthState {}

class SignOutSuccess extends AuthState {}

class SignOutFaild extends AuthState {}

class RegisterDriverLoading extends AuthState {}

class RegisterDriversuccess extends AuthState {}

class RegisterDriverfaild extends AuthState {
  final String message;
  RegisterDriverfaild([this.message = '']);
  @override
  List<Object?> get props => [message];
}

class SignInDriverLoading extends AuthState {}

class SignInDriverSuccess extends AuthState {}

class SignInDriverFaild extends AuthState {
  final String message;
  SignInDriverFaild([this.message = '']);
  @override
  List<Object?> get props => [message];
}

class SignOutDriverLoading extends AuthState {}

class SignOutDriverSuccess extends AuthState {}

class SignOutDriverFaild extends AuthState {}

class PasswordRecoveryState extends AuthState {}

class UpdatePasswordLoading extends AuthState {}

class UpdatePasswordSuccess extends AuthState {}

class UpdatePasswordFaild extends AuthState {
  final String message;
  UpdatePasswordFaild([this.message = '']);
  @override
  List<Object?> get props => [message];
}

part of 'profile_edit_cubit.dart';

sealed class ProfileEditState extends Equatable {
  const ProfileEditState();
  @override
  List<Object?> get props => [];
}

final class ProfileEditInitial extends ProfileEditState {
  const ProfileEditInitial();
}

final class ProfileEditLoading extends ProfileEditState {
  const ProfileEditLoading();
}

final class ProfileEditLoaded extends ProfileEditState {
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  const ProfileEditLoaded({required this.name, required this.email, required this.phone, this.avatarUrl});
  @override
  List<Object?> get props => [name, email, phone, avatarUrl];
}

final class ProfileEditSaving extends ProfileEditState {
  const ProfileEditSaving();
}

final class ProfileEditSaved extends ProfileEditState {
  const ProfileEditSaved();
}

final class ProfileEditError extends ProfileEditState {
  final String message;
  const ProfileEditError(this.message);
  @override
  List<Object?> get props => [message];
}

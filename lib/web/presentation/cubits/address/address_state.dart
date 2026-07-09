part of 'address_cubit.dart';

sealed class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

final class AddressInitial extends AddressState {
  const AddressInitial();
}

final class AddressLoading extends AddressState {
  const AddressLoading();
}

final class AddressLoaded extends AddressState {
  final List<Map<String, dynamic>> addresses;
  const AddressLoaded(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

final class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
  @override
  List<Object?> get props => [message];
}

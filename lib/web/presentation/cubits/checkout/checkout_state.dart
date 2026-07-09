part of 'checkout_cubit.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutLoaded extends CheckoutState {
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> addresses;
  final String? selectedAddressId;
  final String phone;
  final int paymentMethod;
  const CheckoutLoaded({
    required this.items,
    required this.addresses,
    this.selectedAddressId,
    required this.phone,
    required this.paymentMethod,
  });
  @override
  List<Object?> get props => [items, addresses, selectedAddressId, phone, paymentMethod];
}

final class CheckoutPlacing extends CheckoutState {
  const CheckoutPlacing();
}

final class CheckoutSuccess extends CheckoutState {
  final String userEmail;
  const CheckoutSuccess({required this.userEmail});
  @override
  List<Object?> get props => [userEmail];
}

final class CheckoutPaymentOpened extends CheckoutState {
  final String userEmail;
  const CheckoutPaymentOpened({required this.userEmail});
  @override
  List<Object?> get props => [userEmail];
}

final class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}

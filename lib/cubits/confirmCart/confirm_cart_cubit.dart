import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveices.dart';

part 'confirm_cart_state.dart';

class ConfirmCartCubit extends Cubit<ConfirmCartState> {
  ConfirmCartCubit(this.cartServeices) : super(ConfirmCartInitial());
  CartServeices cartServeices;
  Future<void> confirmCart({
    int? id,
    String? userId,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? addressLabel,
  }) async {
    if (!isClosed) emit(ConfirmCartLoading());
    var result = await cartServeices.confirmCart(
      id: id ?? 0,
      userId: userId ?? '',
      deliveryAddress: deliveryAddress,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      addressLabel: addressLabel,
    );
    result.fold(
      (failure) {
        if (!isClosed) emit(ConfirmCartFailure(failure.errMessage));
      },
      (success) {
        if (!isClosed) emit(ConfirmCartSuccess(success));
      },
    );
  }
}

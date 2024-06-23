// // ignore_for_file: non_constant_identifier_names

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';

// import '../../data/services/cartServeices/cart_serveices.dart';

// part 'delete_from_cart_state.dart';

// class DeleteFromCartCubit extends Cubit<DeleteFromCartState> {
//   DeleteFromCartCubit(this.cartServeices) : super(DeleteFromCartInitial());
//   final CartServeices cartServeices;

//   Future<void> deleteFromCart({int? cart_id, int? product_id}) async {
//     emit(DeleteFromCartLoading());
//     var result = await cartServeices.deletefromCart(
//         cart_id: cart_id ?? 0, product_id: product_id ?? 0);
//     result.fold(
//       (failure) {
//         print(failure);
//         emit(DeleteFromCartFailure(failure.errMessage));
//       },
//       (success) {

//         GetFromCartCubit(cartServeices).getProductFromCart();
//         emit(DeleteFromCartSuccess(success));
//       },
//     );
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/getTopSeller/getTopSeller.dart';
import '../../data/services/homeServeice/home_serveices.dart';

part 'get_top_seller_state.dart';

class GetTopSellerCubit extends Cubit<GetTopSellerState> {
  GetTopSellerCubit(this.homeServeices) : super(GetTopSellerInitial());
  final HomeServeices homeServeices;
  Future<void> getTopSellerProducts() async {
    if (!isClosed) emit(GetTopSellerLoading());
    var result = await homeServeices.getTopSeller();
    result.fold(
      (failure) {
        if (!isClosed) emit(GetTopSellerFailure(failure.errMessage));
      },
      (getTopSeller) {
        if (!isClosed) emit(GetTopSellerSuccess(getTopSeller));
      },
    );
  }
}

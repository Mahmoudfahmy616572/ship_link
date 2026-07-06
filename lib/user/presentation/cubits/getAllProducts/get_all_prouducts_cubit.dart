import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ship_link/user/data/models/allProducts/all_products.dart';
import 'package:ship_link/user/domain/repositories/home_repository.dart';

part 'get_all_prouducts_state.dart';

class GetAllProuductsCubit extends Cubit<GetAllProuductsState> {
  GetAllProuductsCubit(this.homeServeices) : super(GetAllProuductsInitial());
  final HomeRepository homeServeices;
  Future<void> getAllproducts() async {
    if (!isClosed) emit(GetAllProuductsLoading());
    var result = await homeServeices.getAllproducts();
    result.fold(
      (failure) {
        if (!isClosed) emit(GetAllProuductsFailure(failure.errMessage));
      },
      (product) {
        if (!isClosed) emit(GetAllProuductsSuccess(product));
      },
    );
  }
}

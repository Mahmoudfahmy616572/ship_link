import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/allProducts/all_products.dart';
import '../../data/services/homeServeice/home_serveices.dart';

part 'get_all_prouducts_state.dart';

class GetAllProuductsCubit extends Cubit<GetAllProuductsState> {
  GetAllProuductsCubit(this.homeServeices) : super(GetAllProuductsInitial());
  final HomeServeices homeServeices;
  Future<void> getAllproducts() async {
    emit(GetAllProuductsLoading());
    var result = await homeServeices.getAllproducts();
    result.fold(
      (failure) {
        emit(GetAllProuductsFailure(failure.errMessage));
      },
      (product) {
        emit(GetAllProuductsSuccess(product));
      },
    );
  }
}

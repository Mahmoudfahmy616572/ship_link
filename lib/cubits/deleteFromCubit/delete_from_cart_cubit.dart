import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'delete_from_cart_state.dart';

class DeleteFromCartCubit extends Cubit<DeleteFromCartState> {
  DeleteFromCartCubit() : super(DeleteFromCartInitial());
}

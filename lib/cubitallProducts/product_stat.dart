abstract class ProductState {}

class InitialState extends ProductState {}

class ProductLoading extends ProductState {}

class ProductSuccess extends ProductState {}

class ProductFaild extends ProductState {}

// ============Add State============
class AddLoading extends ProductState {}

class AddSuccess extends ProductState {
  final String success;
  AddSuccess(this.success);
}

class AddFaild extends ProductState {}

//============getCart State============
class GetCartLoading extends ProductState {}

class GetCartSuccess extends ProductState {}

class GetCartFaild extends ProductState {}

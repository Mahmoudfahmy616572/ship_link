import 'package:bloc/bloc.dart';
import 'package:ship_link/web/presentation/cubits/homeFilter/home_filter_state.dart';

export 'package:ship_link/web/presentation/cubits/homeFilter/home_filter_state.dart';

class HomeFilterCubit extends Cubit<HomeFilterState> {
  HomeFilterCubit() : super(const HomeFilterState());

  void toggleCategory(String category) {
    final current = state.selectedCategories;
    final updated = current.contains(category) ? <String>{} : {category};
    emit(state.copyWith(selectedCategories: updated, visibleCount: 10));
  }

  void clearFilter() {
    emit(state.copyWith(selectedCategories: <String>{}, visibleCount: 10));
  }

  void setSortBy(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
  }

  void loadMore() {
    emit(state.copyWith(visibleCount: state.visibleCount + 10));
  }
}

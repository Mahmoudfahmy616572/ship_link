import 'package:equatable/equatable.dart';

class HomeFilterState extends Equatable {
  final Set<String> selectedCategories;
  final int visibleCount;
  final String sortBy;

  const HomeFilterState({
    this.selectedCategories = const <String>{},
    this.visibleCount = 10,
    this.sortBy = '',
  });

  HomeFilterState copyWith({
    Set<String>? selectedCategories,
    int? visibleCount,
    String? sortBy,
  }) {
    return HomeFilterState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      visibleCount: visibleCount ?? this.visibleCount,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [selectedCategories, visibleCount, sortBy];
}

part of 'tutorials_bloc.dart';

abstract class TutorialsEvent extends Equatable {
  const TutorialsEvent();

  @override
  List<Object> get props => [];
}

class TutorialsLoadCategories extends TutorialsEvent {}

class TutorialsLoadVideos extends TutorialsEvent {
  final String category;
  final bool isRefresh;
  final bool isLoadMore;

  const TutorialsLoadVideos(
      {required this.category,
      this.isRefresh = false,
      this.isLoadMore = false});

  @override
  List<Object> get props => [category, isRefresh, isLoadMore];
}

class TutorialsSelectCategory extends TutorialsEvent {
  final int index;
  const TutorialsSelectCategory(this.index);

  @override
  List<Object> get props => [index];
}

class TutorialsSearchVideos extends TutorialsEvent {
  final String query;
  const TutorialsSearchVideos(this.query);

  @override
  List<Object> get props => [query];
}

class TutorialsAddViewCount extends TutorialsEvent {
  final String tutorialId;
  const TutorialsAddViewCount(this.tutorialId);

  @override
  List<Object> get props => [tutorialId];
}

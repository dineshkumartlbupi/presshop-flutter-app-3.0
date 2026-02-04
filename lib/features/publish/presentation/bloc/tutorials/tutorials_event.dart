part of 'tutorials_bloc.dart';

abstract class TutorialsEvent extends Equatable {
  const TutorialsEvent();

  @override
  List<Object> get props => [];
}

class TutorialsLoadCategories extends TutorialsEvent {}

class TutorialsLoadVideos extends TutorialsEvent {

  const TutorialsLoadVideos(
      {required this.category,
      this.isRefresh = false,
      this.isLoadMore = false});
  final String category;
  final bool isRefresh;
  final bool isLoadMore;

  @override
  List<Object> get props => [category, isRefresh, isLoadMore];
}

class TutorialsSelectCategory extends TutorialsEvent {
  const TutorialsSelectCategory(this.index);
  final int index;

  @override
  List<Object> get props => [index];
}

class TutorialsSearchVideos extends TutorialsEvent {
  const TutorialsSearchVideos(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

class TutorialsAddViewCount extends TutorialsEvent {
  const TutorialsAddViewCount(this.tutorialId);
  final String tutorialId;

  @override
  List<Object> get props => [tutorialId];
}

import 'package:equatable/equatable.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';

class NewsState extends Equatable {
  final List<News> newsList;
  final News? selectedNews;
  final List<Comment> comments;
  final bool isLoading;
  final String? errorMessage;

  const NewsState({
    this.newsList = const [],
    this.selectedNews,
    this.comments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NewsState copyWith({
    List<News>? newsList,
    News? selectedNews,
    List<Comment>? comments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NewsState(
      newsList: newsList ?? this.newsList,
      selectedNews: selectedNews ?? this.selectedNews,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        newsList,
        selectedNews,
        comments,
        isLoading,
        errorMessage,
      ];
}

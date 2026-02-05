import 'package:equatable/equatable.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';

class NewsState extends Equatable {

  const NewsState({
    this.newsList = const [],
    this.selectedNews,
    this.comments = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
  });
  final List<News> newsList;
  final News? selectedNews;
  final List<Comment> comments;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;

  NewsState copyWith({
    List<News>? newsList,
    News? selectedNews,
    List<Comment>? comments,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return NewsState(
      newsList: newsList ?? this.newsList,
      selectedNews: selectedNews ?? this.selectedNews,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        newsList,
        selectedNews,
        comments,
        isLoading,
        isProcessing,
        errorMessage,
      ];
}

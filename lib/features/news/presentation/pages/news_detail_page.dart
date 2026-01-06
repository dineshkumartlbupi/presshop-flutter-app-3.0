import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';

class NewsDetailPage extends StatelessWidget {
  final String newsId;

  const NewsDetailPage({Key? key, required this.newsId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsBloc>()..add(GetNewsDetailEvent(id: newsId)),
      child: Scaffold(
        appBar: AppBar(title: const Text("News Detail")),
        body: BlocBuilder<NewsBloc, NewsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            } else if (state.selectedNews != null) {
              final news = state.selectedNews!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.mediaUrl != null)
                      Image.network(news.mediaUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover),
                    const SizedBox(height: 16),
                    Text(
                      news.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(news.description),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.favorite,
                            color: news.isLiked == true
                                ? Colors.red
                                : Colors.grey),
                        const SizedBox(width: 4),
                        Text("${news.likesCount ?? 0}"),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment),
                        const SizedBox(width: 4),
                        Text("${news.commentsCount ?? 0}"),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart'; // Assuming DI setup
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/presentation/pages/news_detail_page.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsBloc>()
        ..add(const GetAggregatedNewsEvent(
          lat: 0, // TODO: Get actual location
          lng: 0,
          km: 50,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("News"),
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: BlocBuilder<NewsBloc, NewsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            } else if (state.newsList.isNotEmpty) {
              return ListView.builder(
                itemCount: state.newsList.length,
                itemBuilder: (context, index) {
                  final news = state.newsList[index];
                  return ListTile(
                    title: Text(news.title),
                    subtitle: Text(news.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    leading: news.mediaUrl != null
                        ? Image.network(news.mediaUrl!,
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.article),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailPage(newsId: news.id),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: Text("No news found"));
          },
        ),
      ),
    );
  }
}

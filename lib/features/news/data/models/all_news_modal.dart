class NewsItem {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final String imageUrl;
  final String date;
  final String time; // e.g., "12:36"
  final String fullDateTime; // e.g. "12:36, 10 Sep 2025"
  final String location;
  final int soldCount;
  final double earnings;
  final int viewCount;
  final bool isPublished;
  final bool isMostViewed;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.fullDateTime,
    required this.location,
    required this.soldCount,
    required this.earnings,
    required this.viewCount,
    required this.isPublished,
    this.isMostViewed = false,
  });
}

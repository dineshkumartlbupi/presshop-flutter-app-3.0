import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:presshop/view/map_and_news/models/marker_model.dart';
import 'package:presshop/view/map_and_news/services/news_service.dart';
import 'package:presshop/view/map_and_news/models/comment_data.dart';

final newsDetailsControllerProvider =
    ChangeNotifierProvider.autoDispose<NewsDetailsController>((ref) {
  return NewsDetailsController();
});

class NewsDetailsController extends ChangeNotifier {
  final NewsDetailsService _service = NewsDetailsService();

  Incident? _incident;
  bool _isLoading = false;
  String? _error;

  Incident? get incident => _incident;
  List<CommentData> _comments = [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CommentData> get comments => _comments;

  Future<void> fetchNewsDetails(String incidentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print("Controller: fetching news details for $incidentId");
    try {
      final result = await _service.getAggregatedNewsDetail(incidentId);
      if (result != null) {
        _incident = result;
        print("Controller: news details loaded successfully");
        await fetchComments(incidentId);
      } else {
        _error = "Failed to load news details";
        print("Controller: failed to load news details (result null)");
      }
    } catch (e) {
      _error = e.toString();
      print("Controller: error loading news details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComments(String contentId) async {
    try {
      final result = await _service.getComments(contentId);
      _comments = result;
      notifyListeners();
    } catch (e) {
      print("Error fetching comments in controller: $e");
    }
  }

  void addCommentLocal(CommentData comment, {String? parentId}) {
    if (parentId != null) {
      // Find parent and add reply
      for (var c in _comments) {
        if (c.id == parentId) {
          c.replies.add(comment);
          notifyListeners();
          return;
        }
      }
    } else {
      _comments.insert(0, comment);
      notifyListeners();
    }
  }

  void updateLikeLocal(String commentId, int count) {
    for (var c in _comments) {
      if (c.id == commentId) {
        c.likes = count;
        notifyListeners();
        return;
      }
      for (var r in c.replies) {
        if (r.id == commentId) {
          r.likes = count;
          notifyListeners();
          return;
        }
      }
    }
  }

  void toggleLikeStatus(String commentId, bool isLiked) {
    for (var c in _comments) {
      if (c.id == commentId) {
        c.isLiked = isLiked;
        notifyListeners();
        return;
      }
      for (var r in c.replies) {
        if (r.id == commentId) {
          r.isLiked = isLiked;
          notifyListeners();
          return;
        }
      }
    }
  }

  // Allow setting initial incident data if passed from previous screen
  void setInitialIncident(Incident incident) {
    _incident = incident;
    // Don't notify listeners here to avoid rebuild during build if called from initState
  }

  void incrementViewCount() {
    if (_incident != null) {
      final currentViews = _incident?.viewCount ?? 0;
      _incident = _incident?.copyWith(viewCount: currentViews + 1);
      notifyListeners();
    }
  }

  void updateShareCount(int count) {
    if (_incident != null) {
      _incident = _incident?.copyWith(sharesCount: count);
      notifyListeners();
    }
  }
}

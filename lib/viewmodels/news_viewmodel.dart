import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import '../models/article.dart';

class NewsViewModel extends ChangeNotifier {
  final ApiService _newsService = ApiService();
  List<Article> _articles = [];
  bool _isLoading = false;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _articles = await _newsService.fetchArticles();
    } catch (e) {
      print("Error fetching articles: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}

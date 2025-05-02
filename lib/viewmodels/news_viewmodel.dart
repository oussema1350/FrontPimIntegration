import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import '../models/article.dart';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class NewsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Article> _articles = [];
  bool _isLoading = false;

  final Box _readArticlesBox = Hive.box('readArticlesBox');
  final Box _reactionsBox = Hive.box('userReactionsBox');

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _articles = await _apiService.fetchArticles();
      
      // Load saved reactions for each article
      for (int i = 0; i < _articles.length; i++) {
        String key = 'reaction_${_articles[i].id}';
        String? reaction = _reactionsBox.get(key);
        
        // Reset reaction state
        _articles[i].isLiked = false;
        _articles[i].isDisliked = false;
        
        // Apply saved reaction
        if (reaction == 'like') {
          _articles[i].isLiked = true;
        } else if (reaction == 'dislike') {
          _articles[i].isDisliked = true;
        }
      }
    } catch (e) {
      print("Error fetching articles: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Toggle bookmark status for an article
  void toggleBookmark(Article article) {
    final index = _articles.indexOf(article);
    if (index != -1) {
      _articles[index].isBookmarked = !_articles[index].isBookmarked;
      notifyListeners();
    }
  }

  // Get list of bookmarked articles
  List<Article> get bookmarkedArticles {
    return _articles.where((article) => article.isBookmarked).toList();
  }

  // Like/dislike with proper count handling
  Future<void> likeArticle(String articleId) async {
    try {
      final index = _articles.indexWhere((a) => a.id == articleId);
      if (index == -1) return;
      
      // Get the article
      final article = _articles[index];
      String key = 'reaction_$articleId';
      String? currentReaction = _reactionsBox.get(key);
      
      // Handle reaction state:
      if (currentReaction == 'like') {
        // Already liked - do nothing
        return;
      } else if (currentReaction == 'dislike') {
        // Previously disliked - remove dislike and add like
        article.isDisliked = false;
        
        // Update UI immediately for responsiveness
        article.likeCount = 1; // Set like to 1
        article.dislikeCount = 0; // Reset dislike to 0
        article.isLiked = true;
        
        // Store the new reaction
        await _reactionsBox.put(key, 'like');
        
        // Update the server (you may need to adjust this based on your API)
        await _apiService.dislikeArticle(articleId); // Cancel dislike
        await _apiService.likeArticle(articleId); // Add like
      } else {
        // No previous reaction - add like
        article.isLiked = true;
        article.likeCount = 1;
        
        // Store the reaction
        await _reactionsBox.put(key, 'like');
        
        // Update the server
        await _apiService.likeArticle(articleId);
      }
      
      notifyListeners();
    } catch (e) {
      print("❌ Error handling like: $e");
    }
  }

  Future<void> dislikeArticle(String articleId) async {
    try {
      final index = _articles.indexWhere((a) => a.id == articleId);
      if (index == -1) return;
      
      // Get the article
      final article = _articles[index];
      String key = 'reaction_$articleId';
      String? currentReaction = _reactionsBox.get(key);
      
      // Handle reaction state:
      if (currentReaction == 'dislike') {
        // Already disliked - do nothing
        return;
      } else if (currentReaction == 'like') {
        // Previously liked - remove like and add dislike
        article.isLiked = false;
        
        // Update UI immediately for responsiveness
        article.dislikeCount = 1; // Set dislike to 1
        article.likeCount = 0; // Reset like to 0
        article.isDisliked = true;
        
        // Store the new reaction
        await _reactionsBox.put(key, 'dislike');
        
        // Update the server (you may need to adjust this based on your API)
        await _apiService.likeArticle(articleId); // Cancel like
        await _apiService.dislikeArticle(articleId); // Add dislike
      } else {
        // No previous reaction - add dislike
        article.isDisliked = true;
        article.dislikeCount = 1;
        
        // Store the reaction
        await _reactionsBox.put(key, 'dislike');
        
        // Update the server
        await _apiService.dislikeArticle(articleId);
      }
      
      notifyListeners();
    } catch (e) {
      print("❌ Error handling dislike: $e");
    }
  }

  // Mark as Read Feature
  Future<void> markArticleAsRead(String articleId) async {
    await _readArticlesBox.put(articleId, true);
    notifyListeners();
  }

  bool isArticleRead(String articleId) {
    return _readArticlesBox.get(articleId, defaultValue: false);
  }

  void removeArticle(Article article) {
    _articles.removeWhere((a) => a.id == article.id);
    notifyListeners();
  }
}
import 'package:hive/hive.dart';
import '../models/news_article.dart';
import '../providers/news_api_provider.dart';
import 'package:get/get.dart';

class NewsRepository {
  final NewsApiProvider _apiProvider = NewsApiProvider();
  Box<NewsArticle>? _favoritesBox;
  final RxList<NewsArticle> favorites = <NewsArticle>[].obs;

  // Categories available in the app
  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  Future<void> init() async {
    _favoritesBox = await Hive.openBox<NewsArticle>('favorites');
    await syncFavorites();
  }

  // Sync local favorites with server
  Future<void> syncFavorites() async {
    try {
      // Get server favorites
      final serverFavorites = await _apiProvider.getFavorites();

      // Update local storage
      await _favoritesBox?.clear();
      for (var article in serverFavorites) {
        await _favoritesBox?.put(article.id ?? article.url ?? article.title, article);
      }

      // Update reactive list
      favorites.value = serverFavorites;
    } catch (e) {
      print('Error syncing favorites: $e');
      // Fall back to local favorites
      if (_favoritesBox != null) {
        favorites.value = _favoritesBox!.values.toList();
      }
    }
  }

  Future<List<NewsArticle>> getTopHeadlines({
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _apiProvider.getTopHeadlines(
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<List<NewsArticle>> searchNews(
    String query, {
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _apiProvider.searchNews(
      query,
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }

  List<NewsArticle> getFavorites() {
    return favorites;
  }

  Future<void> addToFavorites(NewsArticle article) async {
    try {
      final articleId = article.id ?? article.url ?? article.title;
      // Check if already favorited
      if (favorites.any((a) => (a.id ?? a.url ?? a.title) == articleId)) {
        return; // Already in favorites
      }

      // Add to server
      await _apiProvider.addToFavorites(article);

      // Add to local storage
      await _favoritesBox?.put(articleId, article);

      // Update reactive list
      favorites.add(article);
    } catch (e) {
      print('Error adding to favorites: $e');
      throw e;
    }
  }

  Future<void> removeFromFavorites(NewsArticle article) async {
    try {
      final articleId = article.id ?? article.url ?? article.title;

      // Remove from server
      await _apiProvider.removeFromFavorites(articleId);

      // Remove from local storage
      await _favoritesBox?.delete(articleId);

      // Update reactive list
      favorites.removeWhere((a) => (a.id ?? a.url ?? a.title) == articleId);
    } catch (e) {
      print('Error removing from favorites: $e');
      throw e;
    }
  }

  bool isFavorite(NewsArticle article) {
    final articleId = article.id ?? article.url ?? article.title;
    return favorites.any((a) => (a.id ?? a.url ?? a.title) == articleId);
  }
}

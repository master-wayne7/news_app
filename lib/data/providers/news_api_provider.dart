import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/news_article.dart';
import 'package:dio/dio.dart';

class NewsApiProvider {
  late final Dio _dio;

  NewsApiProvider() {
    final baseUrl = dotenv.env['CUSTOM_API_URL'] ?? 'http://localhost:3000/api';
    print('Using API URL: $baseUrl');

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  // Custom API fallback methods
  Future<List<NewsArticle>> getTopHeadlines({
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          if (category != null) 'category': category,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      }
      return [];
    } catch (e) {
      print('Error details: $e');
      if (e is DioException) {
        print('Error type: ${e.type}');
        print('Error message: ${e.message}');
        print('Error response: ${e.response}');
      }
      return [];
    }
  }

  Future<List<NewsArticle>> searchNews(
    String query, {
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          if (category != null) 'category': category,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching news: $e');
      return [];
    }
  }

  Future<List<NewsArticle>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      throw e;
    }
  }

  Future<void> addToFavorites(NewsArticle article) async {
    try {
      await _dio.post('/favorites', data: article.toJson());
    } catch (e) {
      print('Error adding to favorites: $e');
      throw e;
    }
  }

  Future<void> removeFromFavorites(String articleId) async {
    try {
      // URL encode the articleId to handle special characters
      final encodedId = Uri.encodeComponent(articleId);
      print('Removing favorite with ID: $articleId');

      final response = await _dio.delete('/favorites/$encodedId');
      if (response.statusCode != 200) {
        throw Exception('Failed to remove favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      throw e;
    }
  }
}

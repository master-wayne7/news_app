import 'package:get/get.dart';
import 'dart:async';
import '../../data/models/news_article.dart';
import '../../data/repositories/news_repository.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final NewsRepository _repository = Get.find<NewsRepository>();
  Timer? _debounce;

  final RxList<NewsArticle> articles = <NewsArticle>[].obs;
  final RxList<NewsArticle> filteredArticles = <NewsArticle>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'general'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxString error = ''.obs;
  final RxSet<String> favorites = <String>{}.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
    _loadFavorites();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void _loadFavorites() {
    favorites.assignAll(_repository.getFavorites().map((article) => article.id ?? article.url ?? article.title));
  }

  void changeCategory(String category) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      _currentPage = 1;
      hasMoreData.value = true;
      if (!isSearching.value) {
        articles.clear();
        fetchNews();
      } else {
        filteredArticles.clear();
        _performSearch(searchQuery.value);
      }
    }
  }

  Future<void> fetchNews({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      _currentPage = 1;
      articles.clear();
    }
    error.value = '';

    try {
      final fetchedArticles = await _repository.getTopHeadlines(
        category: selectedCategory.value != 'general' ? selectedCategory.value : null,
        page: loadMore ? _currentPage + 1 : _currentPage,
        pageSize: _pageSize,
      );

      if (fetchedArticles.isEmpty) {
        if (!loadMore) error.value = 'No articles found';
        hasMoreData.value = false;
      } else {
        if (!loadMore) {
          articles.clear();
          _currentPage = 1;
        }
        articles.addAll(fetchedArticles);
        filteredArticles.value = articles;
        _currentPage++;
        hasMoreData.value = fetchedArticles.length >= _pageSize;
      }
    } catch (e) {
      error.value = 'Failed to load news articles: $e';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      clearSearch();
      return;
    }

    searchQuery.value = query;
    isSearching.value = true;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    isLoading.value = true;
    error.value = '';
    _currentPage = 1;
    filteredArticles.clear();

    try {
      final searchResults = await _repository.searchNews(
        query,
        category: selectedCategory.value != 'general' ? selectedCategory.value : null,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (searchResults.isEmpty) {
        error.value = 'No results found for "$query"';
        hasMoreData.value = false;
      } else {
        filteredArticles.value = searchResults;
        _currentPage++;
        hasMoreData.value = searchResults.length >= _pageSize;
      }
    } catch (e) {
      error.value = 'Failed to search articles: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    searchQuery.value = '';
    isSearching.value = false;
    _currentPage = 1;
    hasMoreData.value = true;
    fetchNews();
  }

  bool isFavorite(NewsArticle article) {
    final articleId = article.id ?? article.url ?? article.title;
    return favorites.contains(articleId);
  }

  Future<void> toggleFavorite(NewsArticle article) async {
    final articleId = article.id ?? article.url ?? article.title;
    try {
      if (isFavorite(article)) {
        await _repository.removeFromFavorites(article);
        favorites.remove(articleId);
        Get.snackbar(
          'Success',
          'Article removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _repository.addToFavorites(article);
        favorites.add(articleId);
        Get.snackbar(
          'Success',
          'Article added to favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Revert the local state if the API call failed
      if (isFavorite(article)) {
        favorites.add(articleId);
      } else {
        favorites.remove(articleId);
      }
    }
    update();
  }
}

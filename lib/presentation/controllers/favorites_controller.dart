import 'package:get/get.dart';
import '../../data/models/news_article.dart';
import '../../data/repositories/news_repository.dart';

class FavoritesController extends GetxController {
  final NewsRepository _repository = Get.find<NewsRepository>();

  final RxList<NewsArticle> favorites = <NewsArticle>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    try {
      isLoading.value = true;
      favorites.value = _repository.getFavorites();
    } catch (e) {
      print('Error loading favorites: $e');
      favorites.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromFavorites(NewsArticle article) async {
    try {
      await _repository.removeFromFavorites(article);
      loadFavorites();
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }
}

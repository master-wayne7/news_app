import 'package:get/get.dart';
import 'data/repositories/news_repository.dart';
import 'presentation/controllers/home_controller.dart';
import 'presentation/controllers/favorites_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register repository
    Get.put<NewsRepository>(NewsRepository(), permanent: true);

    // Register controllers
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<FavoritesController>(FavoritesController(), permanent: true);
  }
}

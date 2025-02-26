import 'package:get/get.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/favorites_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: '/',
      page: () => HomePage(),
    ),
    GetPage(
      name: '/favorites',
      page: () => FavoritesPage(),
    ),
  ];
}

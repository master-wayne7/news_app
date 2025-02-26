import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/news_card.dart';
import 'news_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesController controller = Get.find<FavoritesController>();

  FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Articles'),
      ),
      body: Obx(() {
        if (controller.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No favorite articles yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Articles you save will appear here',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final article = controller.favorites[index];
            return NewsCard(
              article: article,
              isFavorite: true,
              onFavoriteToggle: () => controller.removeFromFavorites(article),
              onTap: () => Get.to(() => NewsDetailPage(article: article)),
            );
          },
        );
      }),
    );
  }
}

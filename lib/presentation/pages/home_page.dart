import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/data/repositories/news_repository.dart';
import '../controllers/home_controller.dart';
import '../widgets/news_card.dart';
import '../widgets/category_selector.dart';
import 'news_detail_page.dart';
import '../widgets/news_card_shimmer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!controller.isLoading.value && !controller.isLoadingMore.value && controller.hasMoreData.value) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll - 200) {
        // Load more when 200px from bottom
        controller.fetchNews(loadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.isSearching.value
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search news...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: controller.onSearchQueryChanged,
              )
            : Text('News App')),
        actions: [
          Obx(() => controller.isSearching.value
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: controller.clearSearch,
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => controller.isSearching.value = true,
                )),
        ],
      ),
      body: Column(
        children: [
          CategorySelector(
            categories: Get.find<NewsRepository>().categories,
            onCategorySelected: controller.changeCategory,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && !controller.isLoadingMore.value) {
                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: 5,
                  itemBuilder: (context, index) => NewsCardShimmer(),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.error.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchNews,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final articles = controller.isSearching.value ? controller.filteredArticles : controller.articles;

              if (articles.isEmpty) {
                return Center(child: Text('No articles found'));
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchNews(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(8),
                  itemCount: articles.length + (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == articles.length) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final article = articles[index];
                    return NewsCard(
                      article: article,
                      isFavorite: controller.isFavorite(article),
                      onFavoriteToggle: () => controller.toggleFavorite(article),
                      onTap: () => Get.to(() => NewsDetailPage(article: article)),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

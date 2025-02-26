import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_article.dart';
import '../controllers/home_controller.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final articleId = article.id ?? article.url ?? article.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName ?? 'Article Details'),
        actions: [
          Obx(() {
            final isFavorite = homeController.favorites.contains(articleId);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => homeController.toggleFavorite(article),
            );
          }),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Check out this article: ${article.title} ${article.url ?? ''}',
                subject: article.title,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Hero(
                tag: article.id ?? article.url ?? article.title,
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Metadata
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMMd().format(article.publishedAt),
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (article.author != null) ...[
                        SizedBox(width: 16),
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.author!,
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 16),

                  // Content
                  if (article.content != null)
                    Text(
                      article.content!,
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),

                  SizedBox(height: 16),

                  // Description
                  if (article.description != null && article.description != article.content)
                    Text(
                      article.description!,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),

                  SizedBox(height: 24),

                  // Read more button
                  if (article.url != null)
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.open_in_new),
                        label: Text('Read Full Article'),
                        onPressed: () async {
                          final url = Uri.parse(article.url!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            Get.snackbar(
                              'Error',
                              'Could not open the article URL',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

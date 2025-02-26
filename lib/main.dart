import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/models/news_article.dart';
import 'data/repositories/news_repository.dart';
import 'app_binding.dart';
import 'presentation/pages/main_page.dart';
import 'routes/app_pages.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(NewsArticleAdapter());

  // Initialize AppBinding
  final binding = AppBinding();
  binding.dependencies();

  // Initialize repository
  await Get.find<NewsRepository>().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBinding(),
      home: MainPage(),
      getPages: AppPages.routes,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  category.capitalizeFirst ?? category,
                  style: TextStyle(
                    color: controller.selectedCategory.value == category ? Colors.white : Colors.black,
                  ),
                ),
                selected: controller.selectedCategory.value == category,
                onSelected: (_) => onCategorySelected(category),
              ),
            ),
          );
        },
      ),
    );
  }
}

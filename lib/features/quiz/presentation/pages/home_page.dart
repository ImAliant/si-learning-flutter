import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_learning_flutter/features/quiz/domain/entities/category.dart';
import 'package:si_learning_flutter/features/quiz/presentation/models/category_card.dart';

import '../providers/quiz_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (categories) => categories,
      orElse: () => <Category>[],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('SILearning')),
      body: HomeUI(categories: categories),
    );
  }
}

class HomeUI extends StatelessWidget {
  final List<Category> categories;

  const HomeUI({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories yet.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Expanded(child: ShowCategories(categories: categories))],
    );
  }
}

class ShowCategories extends StatelessWidget {
  final List<Category> categories;

  const ShowCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox();

    return ListView(
      children: [
        // Full-width first item
        FullWidthCategory(category: categories.first),

        // Grid-like rows
        ...categories.skip(1).toList().asMap().entries.map((entry) {
          return CategoryRow(
            categories: categories.skip(1).skip(entry.key * 2).take(2).toList(),
          );
        }),
      ],
    );
  }
}

class FullWidthCategory extends StatelessWidget {
  final Category category;

  const FullWidthCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: CategoryCard(
        category: category,
        color: Colors.orange,
        onTap: () {
          // Navigator.push(...)
        },
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final List<Category> categories;

  const CategoryRow({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          categories.map((category) {
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1.65,
                child: CategoryCard(
                  category: category,
                  color: Colors.blue,
                  onTap: () {
                    // Navigator.push(...)
                  },
                ),
              ),
            );
          }).toList(),
    );
  }
}

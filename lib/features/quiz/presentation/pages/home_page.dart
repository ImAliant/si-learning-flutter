import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_learning_flutter/features/quiz/domain/entities/category.dart';
import 'package:si_learning_flutter/features/quiz/presentation/models/category_card.dart';
import 'package:si_learning_flutter/features/quiz/presentation/pages/play_quiz_page.dart';
import 'package:si_learning_flutter/features/quiz/presentation/pages/quiz_page.dart';

import '../providers/quiz_providers.dart';

typedef CategoryTapCallback =
    void Function(BuildContext context, Category category);

class PlayCategoriesPage extends StatelessWidget {
  const PlayCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryListPage(
      title: 'Play Quiz',
      onCategoryTap: (context, category) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlayQuizPage(category: category)),
        );
      },
    );
  }
}

class LearnCategoriesPage extends StatelessWidget {
  const LearnCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryListPage(
      title: 'Learn',
      onCategoryTap: (context, category) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => QuizPage(category: category)));
      },
    );
  }
}

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({
    super.key,
    required this.title,
    required this.onCategoryTap,
  });

  final String title;
  final CategoryTapCallback onCategoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (categories) => categories,
      orElse: () => <Category>[],
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: HomeUI(categories: categories, onCategoryTap: onCategoryTap),
    );
  }
}

class HomeUI extends StatelessWidget {
  final List<Category> categories;
  final CategoryTapCallback onCategoryTap;

  const HomeUI({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories yet.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ShowCategories(
            categories: categories,
            onCategoryTap: onCategoryTap,
          ),
        ),
      ],
    );
  }
}

class ShowCategories extends StatelessWidget {
  final List<Category> categories;
  final CategoryTapCallback onCategoryTap;

  const ShowCategories({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox();

    return ListView(
      children: [
        // Full-width first item
        FullWidthCategory(
          category: categories.first,
          onCategoryTap: onCategoryTap,
        ),

        // Grid-like rows
        ...categories.skip(1).toList().asMap().entries.map((entry) {
          return CategoryRow(
            categories: categories.skip(1).skip(entry.key * 2).take(2).toList(),
            onCategoryTap: onCategoryTap,
          );
        }),
      ],
    );
  }
}

class FullWidthCategory extends StatelessWidget {
  final Category category;
  final CategoryTapCallback onCategoryTap;

  const FullWidthCategory({
    super.key,
    required this.category,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: CategoryCard(
        category: category,
        color: Colors.orange,
        onTap: () => onCategoryTap(context, category),
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final List<Category> categories;
  final CategoryTapCallback onCategoryTap;

  const CategoryRow({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

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
                  onTap: () => onCategoryTap(context, category),
                ),
              ),
            );
          }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:si_learning_flutter/features/quiz/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final VoidCallback onTap;
  final Category category;
  final Color color;

  const CategoryCard({
    super.key,
    required this.onTap,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

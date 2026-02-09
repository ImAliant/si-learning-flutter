import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/category_json.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Questions], daos: [QuizDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _prepopulateFromAssets();
    },
  );

  Future<void> _prepopulateFromAssets() async {
    final jsonString = await rootBundle.loadString('assets/questions.json');
    final rawList = json.decode(jsonString) as List<dynamic>;
    final categories =
        rawList
            .map((item) => CategoryJson.fromJson(item as Map<String, dynamic>))
            .toList();

    await transaction(() async {
      await _ensureCategory('Aléatoire');
      await _ensureCategory('Révision');

      for (final category in categories) {
        final categoryId = await _ensureCategory(category.categoryName);

        for (final question in category.questions) {
          await into(questions).insert(
            QuestionsCompanion.insert(
              question: question.question,
              answer: question.answer,
              imageKey: Value(question.image),
              categoryId: categoryId,
              needHelp: const Value(false),
            ),
          );
        }
      }
    });
  }

  Future<int> _ensureCategory(String name) async {
    final existing =
        await (select(categories)
          ..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }

    return into(categories).insert(CategoriesCompanion.insert(name: name));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'si_learning.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftAccessor(tables: [Categories, Questions])
class QuizDao extends DatabaseAccessor<AppDatabase> with _$QuizDaoMixin {
  QuizDao(super.db);

  Stream<List<CategoryEntry>> watchAllCategories() {
    return select(categories).watch();
  }

  Stream<CategoryEntry?> watchCategoryById(int id) {
    return (select(categories)
      ..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Stream<CategoryEntry?> watchCategoryByName(String name) {
    return (select(categories)
      ..where((tbl) => tbl.name.equals(name))).watchSingleOrNull();
  }

  Future<int?> getCategoryIdByName(String name) async {
    final row =
        await (select(categories)
          ..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
    return row?.id;
  }

  Stream<List<QuestionEntry>> watchQuestionsByCategoryId(int categoryId) {
    return (select(questions)
      ..where((tbl) => tbl.categoryId.equals(categoryId))).watch();
  }

  Stream<List<QuestionEntry>> watchQuestionsByCategoryName(
    String categoryName,
  ) {
    final query = select(questions).join([
      innerJoin(categories, categories.id.equalsExp(questions.categoryId)),
    ])..where(categories.name.equals(categoryName));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(questions)).toList(),
    );
  }

  Stream<QuestionEntry?> watchQuestionById(int id) {
    return (select(questions)
      ..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<QuestionEntry>> watchAllQuestions() {
    return select(questions).watch();
  }

  Stream<List<QuestionEntry>> watchQuestionsNeedingHelp() {
    return (select(questions)
      ..where((tbl) => tbl.needHelp.equals(true))).watch();
  }

  Future<int> insertCategory(CategoryEntry entry) {
    return into(categories).insert(entry);
  }

  Future<int> insertQuestion(QuestionEntry entry) {
    return into(questions).insert(entry);
  }

  Future<void> updateQuestion(QuestionEntry entry) {
    return update(questions).replace(entry);
  }
}

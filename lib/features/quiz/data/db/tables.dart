import 'package:drift/drift.dart';

@DataClassName('CategoryEntry')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 128)();
}

@DataClassName('QuestionEntry')
class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get question => text().withLength(min: 1, max: 2000)();
  TextColumn get answer => text().withLength(min: 1, max: 4000)();
  TextColumn get imageKey => text().nullable()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  BoolColumn get needHelp => boolean().withDefault(const Constant(false))();

  List<Index> get indexes => [
    Index('questions_category_idx', [categoryId] as String),
    Index('questions_need_help_idx', [needHelp] as String),
  ];
}

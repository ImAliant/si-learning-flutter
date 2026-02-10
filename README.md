# si_learning_flutter

Flutter quiz application with local SQLite persistence.

## Implemented Features
- Material 3 app shell with title "SI Learning" and a root page that provides Play and Learn tabs via bottom navigation.
- Category listing backed by Riverpod stream providers and Drift database streams.
- Local database (Drift) with Categories and Questions tables, plus indices on categoryId and needHelp.
- Database prepopulation from assets/questions.json on first create, plus two fixed categories for random and revision modes.
- Play mode (GamePage) with a 15s timer per question, text answer input, skip, mark for revision, and restart when complete.
- Learn mode (QuizPage) showing question and answer list; revision category allows removal from revision.
- Category UI includes a featured full-width card followed by grid-like rows.

## Data and Architecture
- Domain entities and use cases, repository interface, and repository implementation backed by a local datasource and Drift DAO.
- Riverpod providers for database, repository, use cases, and data streams.

## Tests
- test/widget_test.dart still contains the default Flutter counter template and does not match the current app widget tree.

## Improvements
- Replace the template widget test with tests for category loading, play flow, and revision toggling.
- Wire up routing and theming through router.dart and theme.dart or remove unused files.
- Remove or integrate the unused PlayQuizPage and the duplicate presentation Category model.
- Add answer validation and scoring for play mode instead of only skip or advance.
- Add database migration handling and a seed refresh strategy beyond initial creation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codealpha_language_learning_app/data/languages_data.dart';
import 'package:codealpha_language_learning_app/data/seed_data_provider.dart';
import 'package:codealpha_language_learning_app/models/category.dart';
import 'package:codealpha_language_learning_app/models/user_progress.dart';
import 'package:codealpha_language_learning_app/screens/flashcards_screen.dart';
import 'package:codealpha_language_learning_app/services/learning_state.dart';
import 'package:codealpha_language_learning_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Data Model & Curriculum Tests', () {
    test(
      'Supported languages include Spanish, French, German, Japanese, Italian',
      () {
        expect(
          LanguagesData.supportedLanguages.length,
          greaterThanOrEqualTo(5),
        );
        final codes = LanguagesData.supportedLanguages
            .map((l) => l.code)
            .toList();
        expect(codes, containsAll(['es', 'fr', 'de', 'ja', 'it']));
      },
    );

    test('Each language has rich vocabulary, daily lessons, and quizzes', () {
      for (final lang in LanguagesData.supportedLanguages) {
        final vocab = SeedDataProvider.getVocabForLanguage(lang.id);
        final lessons = SeedDataProvider.getLessonsForLanguage(lang.id);
        final quizzes = SeedDataProvider.getQuizzesForLanguage(lang.id);

        expect(
          vocab.isNotEmpty,
          isTrue,
          reason: '${lang.name} should have vocabulary',
        );
        expect(
          lessons.isNotEmpty,
          isTrue,
          reason: '${lang.name} should have lessons',
        );
        expect(
          quizzes.isNotEmpty,
          isTrue,
          reason: '${lang.name} should have quizzes',
        );
      }
    });

    test('Category mappings exist for vocabulary, grammar, and phrases', () {
      expect(LearningCategory.allCategories.length, greaterThanOrEqualTo(5));
      final vocabCat = LearningCategory.fromType(CategoryType.vocabulary);
      expect(vocabCat.title, equals('Vocabulary'));
      final grammarCat = LearningCategory.fromType(CategoryType.grammar);
      expect(grammarCat.title, equals('Grammar'));
    });

    test('UserProgress calculates level and XP accurately', () {
      const p1 = UserProgress(totalXp: 50);
      expect(p1.level, equals(1));
      expect(p1.levelTitle, equals('Curious Beginner'));

      const p2 = UserProgress(totalXp: 250);
      expect(p2.level, equals(3));
      expect(p2.levelTitle, equals('Active Explorer'));

      const p3 = UserProgress(totalXp: 650);
      expect(p3.level, equals(7));
      expect(p3.levelTitle, equals('Fluent Apprentice'));
    });
  });

  group('Widget Smoke Tests', () {
    testWidgets('LexoraApp launches and displays Splash branding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LexoraApp());
      expect(find.text('Lexora'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('FlashcardsScreen loads and toggles shuffle cleanly', (
      WidgetTester tester,
    ) async {
      final state = LearningState();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlashcardsScreen(learningState: state)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlashcardsScreen), findsOneWidget);

      final shuffleBtn = find.byTooltip('Shuffle Deck');
      expect(shuffleBtn, findsOneWidget);

      // Tap shuffle and verify cards remain loaded and valid
      await tester.tap(shuffleBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Card 1 of'), findsOneWidget);
    });
  });
}

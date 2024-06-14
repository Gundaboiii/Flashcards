import 'dart:convert';
import '../views/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/decklist.dart';

Future<void> loadJSONData(DBHelper dbHelper) async {
  final jsonContent = await rootBundle.loadString('assets/flashcards.json');
  final List<dynamic> jsonList = jsonDecode(jsonContent);

  for (final dynamic map in jsonList) {
    final deckTitle = map['title'];
    final flashcards = map['flashcards'];

    final deck = Deck(title: deckTitle);
    final deckId = await dbHelper.insertDeck(deck);

    for (final flashcardMap in flashcards) {
      final question = flashcardMap['question'];
      final answer = flashcardMap['answer'];

      final flashcard = Flashcard(
        deckId: deckId,
        question: question,
        answer: answer,
      );

      await dbHelper.insertFlashcard(flashcard);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  //databaseFactory = databaseFactoryFfi;

  final dbHelper = DBHelper();
  await dbHelper.initDatabase();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DeckList(),
  ));
}

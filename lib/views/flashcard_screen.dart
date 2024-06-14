import 'package:flutter/material.dart';
import 'dart:math';
import 'decklist.dart';
import 'db_helper.dart';
import 'edit_flashcard_screen.dart';
import 'quizscreen.dart';

class FlashcardScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardScreen({required this.deck, super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState(deck);
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final Deck deck;
  List<Flashcard> flashcards = [];
  bool ascendingOrder = false;
  bool showAnswer = false;

  _FlashcardScreenState(this.deck);

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  void loadFlashcards() async {
    final dbHelper = DBHelper();
    final loadedFlashcards = await dbHelper.getFlashcardsByDeckId(deck.id!);

    setState(() {
      flashcards = loadedFlashcards;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth ~/ 200;
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: () {
              toggleSortOrder();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              navigateToQuizTime();
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2,
        ),
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = flashcards[index];
          return Card(
            color: Colors.orange,
            child: InkWell(
              onTap: () {
                navigateToEditFlashcard(flashcard);
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' ${flashcard.question}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    if (showAnswer)
                      Text(
                        ' ${flashcard.answer}',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddFlashcard();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToAddFlashcard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlashcardScreen(deck: deck),
      ),
    ).then((value) {
      loadFlashcards();
    });
  }

  void toggleSortOrder() {
    setState(() {
      if (ascendingOrder) {
        loadFlashcards();
      } else {
        flashcards.sort((a, b) => a.question.compareTo(b.question));
      }
      ascendingOrder = !ascendingOrder;
    });
  }

  void shuffleFlashcards() {
    final random = Random();
    flashcards.shuffle(random);
  }

  void toggleShowAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void navigateToQuizTime() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTimeScreen(
          flashcards: flashcards,
        ),
      ),
    );
  }

  void navigateToEditFlashcard(Flashcard flashcard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlashcardScreen(flashcard: flashcard),
      ),
    ).then((value) {
      loadFlashcards();
    });
  }
}

class AddFlashcardScreen extends StatefulWidget {
  final Deck deck;

  const AddFlashcardScreen({required this.deck, super.key});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState(deck);
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final Deck deck;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  _AddFlashcardScreenState(this.deck);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveFlashcard();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void saveFlashcard() async {
    final dbHelper = DBHelper();
    final newFlashcard = Flashcard(
      deckId: deck.id!,
      question: questionController.text,
      answer: answerController.text,
    );
    await dbHelper.insertFlashcard(newFlashcard);
    Navigator.pop(context);
  }
}

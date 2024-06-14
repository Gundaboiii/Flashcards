import 'package:flutter/material.dart';
import '../main.dart';
import 'flashcard_screen.dart';
import 'db_helper.dart';
import 'edit_deck_screen.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    loadDecks();
  }

  void loadDecks() async {
    final dbHelper = DBHelper();
    final loadedDecks = await dbHelper.getAllDecks();

    setState(() {
      decks = loadedDecks;
    });
  }

  Future<void> downloadDecks() async {
    final dbHelper = DBHelper();
    await loadJSONData(dbHelper);
    loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = (screenWidth / 200).floor();
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Decks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: downloadDecks,
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.all(4),
        children: List.generate(
            decks.length,
            (index) => Card(
                color: Colors.orange,
                child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        InkWell(onTap: () {
                          navigateToFlashcardsScreen(decks[index]);
                        }),
                        Center(child: Text(decks[index].title)),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              navigateToEditDeck(decks[index]);
                            },
                          ),
                        ),
                      ],
                    )))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddDeck();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToAddDeck() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDeckScreen(),
      ),
    ).then((value) {
      loadDecks();
    });
  }

  void navigateToFlashcardsScreen(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(deck: deck),
      ),
    );
  }

  void navigateToEditDeck(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDeckScreen(deck: deck),
      ),
    ).then((value) {
      loadDecks();
    });
  }
}

class Deck {
  int? id;
  String title;

  Deck({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class Flashcard {
  int? id;
  int deckId;
  String question;
  String answer;

  Flashcard(
      {this.id,
      required this.deckId,
      required this.question,
      required this.answer});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'question': question,
      'answer': answer,
    };
  }
}

// To add a new deck
class AddDeckScreen extends StatefulWidget {
  const AddDeckScreen({super.key});

  @override
  State<AddDeckScreen> createState() => _AddDeckScreenState();
}

class _AddDeckScreenState extends State<AddDeckScreen> {
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Deck Title'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveDeckTitle();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void saveDeckTitle() async {
    final dbHelper = DBHelper();
    final newDeck = Deck(title: titleController.text);
    await dbHelper.insertDeck(newDeck);
    Navigator.pop(context);
  }
}

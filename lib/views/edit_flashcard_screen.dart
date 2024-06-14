import 'package:flutter/material.dart';
import 'decklist.dart';
import 'db_helper.dart';

class EditFlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;

  const EditFlashcardScreen({required this.flashcard, super.key});

  @override
  State<EditFlashcardScreen> createState() =>
      _EditFlashcardScreenState(flashcard);
}

class _EditFlashcardScreenState extends State<EditFlashcardScreen> {
  final Flashcard flashcard;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  _EditFlashcardScreenState(this.flashcard);

  @override
  void initState() {
    super.initState();
    questionController.text = flashcard.question;
    answerController.text = flashcard.answer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Flashcard'),
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
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveFlashcardContent();
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    deleteFlashcard();
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void saveFlashcardContent() async {
    final dbHelper = DBHelper();
    await dbHelper.updateFlashcardContent(
      flashcard.id!,
      questionController.text,
      answerController.text,
    );
    Navigator.pop(context);
  }

  void deleteFlashcard() async {
    final dbHelper = DBHelper();
    await dbHelper.deleteFlashcard(flashcard.id!);
    Navigator.pop(context);
  }
}

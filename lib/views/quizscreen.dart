import 'package:flutter/material.dart';
import 'decklist.dart';

class QuizTimeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const QuizTimeScreen({required this.flashcards, Key? key}) : super(key: key);

  @override
  State<QuizTimeScreen> createState() => _QuizTimeScreenState(flashcards);
}

class _QuizTimeScreenState extends State<QuizTimeScreen> {
  List<Flashcard> flashcards;
  int currentFlashcardIndex = 0;
  bool isFlipped = false;

  int seen = 1;
  int flip = 0;
  int peek = 0;
  int answer = 1;

  List<Flashcard> shuffledFlashcards = [];
  List<int> flippedCards = [];
  List<int> seenedCards = [0];

  _QuizTimeScreenState(this.flashcards);

  @override
  void initState() {
    super.initState();
    shuffledFlashcards = List<Flashcard>.from(widget.flashcards)..shuffle();
  }

  void showPreviousFlashcard() {
    if (currentFlashcardIndex > 0) {
      setState(() {
        currentFlashcardIndex--;
        if (!seenedCards.contains(currentFlashcardIndex)) {
          seen++;
          seenedCards.add(currentFlashcardIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    } else {
      setState(() {
        currentFlashcardIndex = shuffledFlashcards.length - 1;
        if (!seenedCards.contains(currentFlashcardIndex)) {
          seen++;
          seenedCards.add(currentFlashcardIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    }
  }

  void showNextFlashcard() {
    if (currentFlashcardIndex < shuffledFlashcards.length - 1) {
      setState(() {
        currentFlashcardIndex++;
        if (!seenedCards.contains(currentFlashcardIndex)) {
          seen++;
          seenedCards.add(currentFlashcardIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    } else {
      setState(() {
        currentFlashcardIndex = 0;
        if (!seenedCards.contains(currentFlashcardIndex)) {
          seen++;
          seenedCards.add(currentFlashcardIndex);
        }
        isFlipped = false;
        answer = seen;
      });
    }
  }

  void toggleAnswerReveal() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped &&
          seenedCards.contains(currentFlashcardIndex) &&
          !flippedCards.contains(currentFlashcardIndex)) {
        flip++;
        answer = seen;
        flippedCards.add(currentFlashcardIndex);
        peek++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Time'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFlipped
                      ? const Color.fromARGB(255, 136, 214, 46)
                      : const Color.fromARGB(255, 255, 175, 26),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  isFlipped
                      ? shuffledFlashcards[currentFlashcardIndex].answer
                      : shuffledFlashcards[currentFlashcardIndex].question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_sharp),
                    onPressed: showPreviousFlashcard,
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_to_front_outlined),
                    onPressed: toggleAnswerReveal,
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_sharp),
                    onPressed: showNextFlashcard,
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                'Seen: $seen out of ${shuffledFlashcards.length} cards',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Peeked at $peek out of $answer answers',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
  }
}

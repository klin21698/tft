import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tft/character.dart';
import 'package:tft/trait.dart';
import 'dart:html';

void main() {
  window.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // Sets some constants.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFTdle',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const Quiz(), // MyApp calls the Quiz widget here
      debugShowCheckedModeBanner: false,
    );
  }
}

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  // These are all the variables that the quiz needs
  // Controller is used for the search function to get the text from the controller
  final TextEditingController _textEditingController = TextEditingController();
  // _allCharacters is a list of all of the characters defined from character.dart
  final List<Character> _allCharacters = characters;
  // _selectedCharacters is a list of the characters that the user selects
  final List<Character> _selectedCharacters = [];
  // _wrongCharacters is a set of the wrong characters, used for displaying the red outline
  final Set<String> _wrongCharacters = {};
  // _dailyQuiz is a list of the desired traits that the user wants to activate
  final DailyQuiz _dailyQuiz = dailyQuizzes[
      0]; // TODO: find a way to sample a random daily quiz based on today's date
  // keeping track of the number of attempts
  int _attempts = 5;
  // if showRedOutline true, then we show the red outline
  bool _showRedOutline = false;

  @override
  void initState() {
    super.initState();
    document.onContextMenu
        .listen((event) => event.preventDefault()); // Don't worry about this
  }

  bool _calculateCorrect() {
    // We call this function on submit. Calculates whether the user got the quiz right
    // Keeps track of the wrong characters so we can add red outlines around them
    setState(() {
      _attempts -= 1;
    });
    bool correct = true;
    _wrongCharacters.clear();
    for (int i = 0; i < _selectedCharacters.length; i++) {
      if (!_dailyQuiz.correctCharacters.contains(_selectedCharacters[i].name)) {
        _wrongCharacters.add(_selectedCharacters[i].name);
        correct = false;
      }
    }
    for (int i = 0; i < _dailyQuiz.correctCharacters.length; i++) {
      if (!_selectedCharacters
          .map((e) => e.name)
          .contains(_dailyQuiz.correctCharacters[i])) {
        correct = false;
      }
    }
    return correct;
  }

  Widget _characterWidget(String characterName, bool inSelectedList) {
    // Shows an individual character, including the red outline if it's wrong
    bool wrong = _showRedOutline &&
        _wrongCharacters.contains(characterName) &&
        inSelectedList;
    if (wrong) {
      return SizedBox(
          width: 100,
          height: 100,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            child: Center(
                child: Image.asset(
                    'assets/characters/${characterName.replaceAll(" ", "")}.png')),
          ));
    }
    return SizedBox(
        width: 100,
        height: 100,
        child: Center(
            child: Image.asset(
                'assets/characters/${characterName.replaceAll(" ", "")}.png')));
  }

  List<Widget> _searchedCharacterWidgets() {
    // Shows all of the searched characters. If text field is empty, show all.
    // If not empty, show the characters that start with the text in text box
    List<Widget> res = [];
    if (_textEditingController.text == "") {
      for (Character character in _allCharacters) {
        res.add(GestureDetector(
            onTap: () {
              setState(() {
                _showRedOutline = false;
              });
              if (_selectedCharacters.length < 9) {
                setState(() {
                  if (!_selectedCharacters.contains(character)) {
                    _selectedCharacters.add(character);
                  }
                });
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text('Too many champions!'),
                          content: const Text(
                              'Please remove a champion before adding another one'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok'))
                          ]);
                    });
              }
            },
            child: _characterWidget(character.name, false)));
      }
    } else {
      for (Character character in _allCharacters) {
        if (character.name
            .toLowerCase()
            .startsWith(_textEditingController.text.toLowerCase())) {
          res.add(GestureDetector(
              onTap: () {
                setState(() {
                  _showRedOutline = false;
                });
                if (_selectedCharacters.length < 9) {
                  setState(() {
                    if (!_selectedCharacters.contains(character)) {
                      _selectedCharacters.add(character);
                    }
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: const Text('Too many champions!'),
                            content: const Text(
                                'Please remove a champion before adding another one'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Ok'))
                            ]);
                      });
                }
              },
              child: _characterWidget(character.name, false)));
        }
      }
    }
    return res;
  }

  List<Widget> _selectedCharacterWidgets() {
    // Show the characters that the user selects
    List<Widget> res = [];
    for (Character character in _selectedCharacters) {
      res.add(GestureDetector(
          onTap: () {
            setState(() {
              _showRedOutline = false;
              _selectedCharacters.removeWhere((selectedCharacter) =>
                  selectedCharacter.name == character.name);
            });
          },
          onSecondaryTap: () {
            setState(() {
              _showRedOutline = false;
              _selectedCharacters.removeWhere((selectedCharacter) =>
                  selectedCharacter.name == character.name);
            });
          },
          child: _characterWidget(character.name, true)));
    }
    return res;
  }

  List<Widget> _traitWidgets() {
    // Shows the traits that the user is going for
    List<Widget> res = [];
    for (QuizTrait quizTrait in _dailyQuiz.quizTraits) {
      res.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                  'assets/traits/${quizTrait.trait.name.toLowerCase()}.png',
                  color: Colors.white),
            ),
            Container(
                // TODO: Depending on the quizTrait.desiredLevel, assign different colors
                // bronze, silver, gold, etc
                decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    border: Border.all(
                      color: Colors.grey.shade800,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6))),
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(quizTrait.desiredLevel.toString()))),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: [
                  Text(quizTrait.trait.name,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ));
    }
    return res;
  }

  Widget _formatTraitWidgets(List<Widget> traitWidgets) {
    // Formatting these widgets in case there's more than 1 row.
    // Each row has up to 3 widgets
    List<Widget> columnWidgets = [];
    for (int i = 0; i < traitWidgets.length; i += 3) {
      columnWidgets.add(Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: traitWidgets.sublist(i, min(i + 3, traitWidgets.length))),
      ));
    }
    return Column(children: columnWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TFTdle"), // The app bar at the top
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            // This is the column of widgets that gets built (and the user sees)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // This widget contains all desired traits
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _formatTraitWidgets(_traitWidgets())),
                // This widget contains the selected characters. If there are non selected characters, then it will display a text
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                      width: 450,
                      height: 450,
                      child: _selectedCharacters.isEmpty
                          ? Center(
                              child: Text(
                                  "Select the correct champions to activate the traits!",
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.displaySmall))
                          : GridView.count(
                              crossAxisCount: 3,
                              children: _selectedCharacterWidgets(),
                            )),
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() => _showRedOutline = true);
                      if (_attempts == 0) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: const Text(
                                      'You have no attempts remaining'),
                                  content: const Text(
                                      'Please come again tomorrow for a new quiz'),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ok'))
                                  ]);
                            });
                      } else {
                        bool correct = _calculateCorrect();
                        if (correct) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: const Text('Correct!'),
                                    content: Text(
                                        'You solved it in ${5 - _attempts} attempts!'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Ok'))
                                    ]);
                              });
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: const Text('Incorrect!'),
                                    content: Text(
                                        'You have $_attempts attempts remaining!'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Ok'))
                                    ]);
                              });
                        }
                      }
                    },
                    child: Text('Submit',
                        style: Theme.of(context).textTheme.bodyLarge!)),
                // This widget contains the text field for search functionality
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: TextField(
                    controller: _textEditingController,
                    decoration:
                        const InputDecoration(hintText: "Search champions"),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                // This widget contains the characters that the user searched for
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                      width: 450,
                      height: 900,
                      child: GridView.count(
                          crossAxisCount: 3,
                          children: _searchedCharacterWidgets())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

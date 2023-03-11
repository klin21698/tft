import 'dart:math';
import 'package:intl/intl.dart';
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
      title: 'TRAITLE',
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
//final now = new DateTime.M();
 //String formatter = DateFormat.M().format(now);
 //print(formatter);
  
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
  late DailyQuiz _dailyQuiz; // TODO: find a way to sample a random daily quiz based on today's date
 
  
  // keeping track of the number of attempts
  int _attempts = 5;
  // if showRedOutline true, then we show the red outline
  bool _showRedOutline = false;

  @override
  void initState() {
    super.initState();
    _dailyQuiz = determineQuiz();
    document.onContextMenu
        .listen((event) => event.preventDefault()); // Don't worry about this
  }
  
  DailyQuiz determineQuiz() {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    int quizNum = (30*date.month)+date.day;
    //print(quizNum.toString() + " " + (quizNum%dailyQuizzes.length).toString());
    return dailyQuizzes[quizNum%dailyQuizzes.length];
  }
 
  bool _calculateCorrect() {
    // We call this function on submit. Calculates whether the user got the quiz right
    // Keeps track of the wrong characters so we can add red outlines around them
    setState(() {
      _attempts -= 1;
    });
    bool res = false;
    _wrongCharacters.clear();
    //_dailyQuiz.correctCorrecters: List<List<String>>, whereas _selectedCharacters: List<String>
    Map<String, int> wrongCharactersMap = {};
    // {k1:v1, k2:v2}
    // }styop
    for(List<String> correctCharactersList in _dailyQuiz.correctCharacters){
      bool correct = true;
      for (int i = 0; i < _selectedCharacters.length; i++) {
        if (!correctCharactersList.contains(_selectedCharacters[i].name)) {
          // _wrongCharacters.add(_selectedCharacters[i].name);
          if(wrongCharactersMap.containsKey(_selectedCharacters[i].name)){
            wrongCharactersMap[_selectedCharacters[i].name] = wrongCharactersMap[_selectedCharacters[i].name]! + 1;
          }else{ 
                wrongCharactersMap[_selectedCharacters[i].name] = 1;
          }
          
          correct = false;
        }
      }
      for (int i = 0; i < correctCharactersList.length; i++) {
        if (!_selectedCharacters
            .map((e) => e.name)
            .contains(correctCharactersList[i])) {
          correct = false;
        }
      }
      for(String character in wrongCharactersMap.keys){
        int timesInWrongCharactersMap = wrongCharactersMap[character]!;
        if (timesInWrongCharactersMap == _dailyQuiz.correctCharacters.length){
          _wrongCharacters.add(character);
        }
      }
      res = res || correct;
    }
    return res;
  }

  Widget _characterWidget(String characterName, bool inSelectedList) {
    // Shows an individual character, including the red outline if it's wrong
    bool wrong = _showRedOutline &&
        _wrongCharacters.contains(characterName) &&
        inSelectedList;
    if (wrong) {
      return SizedBox(
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            child: Center(
                child: Image.asset(
                    'assets/characters/${characterName.replaceAll(" ", "")}.png')),
          ));
    }
    return SizedBox(
        width: 30,
        height: 30,
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
      // breakpoints=[2,4] and desiredLevel=5
      int index = -1;
      for (int i = 0; i < quizTrait.trait.breakpoints.length; i++) {
        if (quizTrait.trait.breakpoints[i] <= quizTrait.desiredLevel) {
          index = i;
        }
      }
    
      Color brown = Colors.brown.shade800;
      Color gold = Colors.yellow.shade700;
      Color silver = Colors.grey.shade700;
      Color backgroundColor = Colors.black87;
       if (quizTrait.trait.breakpoints.length == 1) {
          backgroundColor = gold;
      }
      if (quizTrait.trait.breakpoints.length == 2) {
        if (index == 0) {
          backgroundColor = brown;
        }
        if (index == 1) {
          backgroundColor = gold;
        }
      }
      if (quizTrait.trait.breakpoints.length == 3) {
        if (index == 0) {
          backgroundColor = brown;
        }
        if (index == 1) {
          backgroundColor = silver;
        }
        if (index == 2) {
          backgroundColor = gold;
        }
      }
      if (quizTrait.trait.breakpoints.length == 4) {
        if (index == 0) {
          backgroundColor = brown;
        }
        if (index == 1) {
          backgroundColor = silver;
        }
        if (index == 2) {
          backgroundColor = gold;
        }
        if (index == 3) {
          backgroundColor = Colors.purple.shade50;
        }
      }
      res.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                  'assets/traits/${quizTrait.trait.name.toLowerCase()}.png',
                  color: Colors.white, width:18, height: 18),
            ),
            Container(

                decoration: BoxDecoration(
                    color: backgroundColor,
                    // color: backgroundColor,
                    border: Border.all(
                      color: backgroundColor,
                      // color: backgroundColor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6))),
                child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(quizTrait.desiredLevel.toString(), style:Theme.of(context).textTheme.bodyMedium))),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: [
                  Text(quizTrait.trait.name,
                      style: Theme.of(context).textTheme.bodyMedium),
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
        padding: const EdgeInsets.only(top: 10.0),
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
        title: const Text("TRAITLE"), // The app bar at the top
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 700,
            // This is the column of widgets that gets built (and the user sees)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // This widget contains all desired traits
                Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: _formatTraitWidgets(_traitWidgets())),
                // This widget contains the selected characters. If there are non selected characters, then it will display a text
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                      width: 350,
                      height: 350,
                      child: _selectedCharacters.isEmpty
                          ? Center(
                              child: Text(
                                  "Select the correct champions to activate the traits!",
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge))
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
                  child: SizedBox(width:400, child:TextField(
                    controller: _textEditingController,
                    decoration:
                        const InputDecoration(hintText: "Search champions"),
                    onChanged: (value) {
                      setState(() {});
                    },
                  )),
                ),
                // This widget contains the characters that the user searched for
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                      width: 350,
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

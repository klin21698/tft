class Trait {
  final String name;

  Trait(this.name);
}

// TODO: Fill this out, verify this
// If there's extras make sure to put the image in the assets path
List<Trait> traits = [
  Trait('Ace'),
  Trait('Aegis'),
  Trait('Arsenal'),
  Trait('Brawler'),
  Trait('Defender'),
  Trait('Duelist'),
  Trait('Forecaster'),
  Trait('Gadgeteen'),
  Trait('Hacker'),
  Trait('Heart'),
  Trait('Mascot'),
  Trait('Ox Force'),
  Trait('Prankster'),
  Trait('Recon'),
  Trait('Renegade'),
  Trait('Spellslinger'),
  Trait('Sureshot'),
];

class QuizTrait {
  final Trait trait;
  final int desiredLevel;
  QuizTrait(this.trait, this.desiredLevel);
}

// TODO: Fill this out, make at least 30 hardcoded quizzes
class DailyQuiz {
  final List<QuizTrait> quizTraits;
  final List<String> correctCharacters;

  DailyQuiz(this.quizTraits, this.correctCharacters);
}

List<DailyQuiz> dailyQuizzes = [
  DailyQuiz([
    QuizTrait(Trait('Ace'), 3),
    QuizTrait(Trait('Gadgeteen'), 1),
    QuizTrait(Trait('Hacker'), 2),
    QuizTrait(Trait('Sureshot'), 3),
    QuizTrait(Trait('Renegade'), 3)
  ], [
    "Alistar",
    "Blitzcrank",
  ])
];

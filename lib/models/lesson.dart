/// Enum to identify different types of interactive lessons.
/// This allows the backend to return a [lessonType] and the app will dynamically
/// load the corresponding UI template.
enum LessonType {
  /// 2x2 grid of image options where the user taps the correct option.
  selectImageGrid,

  /// Flashcard stack where the user swipes left (correct) or right (incorrect).
  swipeCard,

  /// One image on top and 4 text options stacked vertically below.
  selectTextOption,

  /// Fill in the blank space in a sentence by picking word tiles below.
  fillInBlank,

  /// Select and order letter tiles to spell out the target word.
  orderLetters,

  /// Assemble a sentence in Spanish from word bank based on Alemán Coloniero audio/speech bubble.
  translateAssembleSentence,
}

/// Model class representing a lesson item loaded from the backend or local data.
class LessonItem {
  final String id;
  final LessonType type;
  final String moduleTitle;
  final String questionTitle;
  final String questionSubtitle;
  final String voiceBy;
  final String? audioPath;
  final List<Map<String, String>> options;
  final String targetWord;

  const LessonItem({
    required this.id,
    required this.type,
    required this.moduleTitle,
    required this.questionTitle,
    required this.questionSubtitle,
    required this.voiceBy,
    this.audioPath,
    required this.options,
    required this.targetWord,
  });
}

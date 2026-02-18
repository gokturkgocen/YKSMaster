/// Question model for the quiz system
class Question {
  final int id;
  final String subject;
  final String text;
  final List<String> options;
  final int correctAnswer; // 0-4 for A-E

  const Question({
    required this.id,
    required this.subject,
    required this.text,
    required this.options,
    required this.correctAnswer,
  });
}

/// Sample Turkish questions
const List<Question> sampleQuestions = [
  Question(
    id: 1,
    subject: 'Matematik',
    text:
        'Bir doğrunun eğimi 3/4 ise ve bu doğru (2, 5) noktasından geçiyorsa, doğrunun denklemi nedir?',
    options: [
      'y = (3/4)x + 7/2',
      'y = (3/4)x + 5/2',
      'y = (4/3)x + 7/2',
      'y = (3/4)x + 3/2',
      'y = (4/3)x + 5/2',
    ],
    correctAnswer: 0,
  ),
  Question(
    id: 2,
    subject: 'Türkçe',
    text: 'Aşağıdaki cümlelerin hangisinde bir yazım yanlışı vardır?',
    options: [
      'Arkadaşımla buluşmak için şehir merkezine gittim.',
      'Sınav sonuçları yarın açıklanacakmış.',
      'Herkez bu durumdan çok etkilendi.',
      'Konuşmacı çok güzel bir sunum yaptı.',
      'Kitabı okumayı bitirdikten sonra sana vereceğim.',
    ],
    correctAnswer: 2,
  ),
  Question(
    id: 3,
    subject: 'Türkçe',
    text:
        '"Burası çok sessiz, kuş uçmuyor." cümlesinde altı çizili söz hangi anlamda kullanılmıştır?',
    options: [
      'Çok yalnız ve ıssız olmak',
      'Kuşların göç etmiş olması',
      'Sessizliğin çok derin olması',
      'Kimsenin bulunmaması',
      'Doğanın bozulmuş olması',
    ],
    correctAnswer: 3,
  ),
];

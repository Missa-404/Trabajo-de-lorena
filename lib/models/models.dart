class User {
  final int? id;
  final String username;
  final String password;

  User({this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }
}

class Word {
  final int? id;
  final String word;
  final String description;
  final int? addedBy;

  Word({this.id, required this.word, required this.description, this.addedBy});

  Map<String, dynamic> toMap() {
    return {'id': id, 'word': word, 'description': description, 'added_by': addedBy};
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      word: map['word'] as String,
      description: map['description'] as String,
      addedBy: map['added_by'] as int?,
    );
  }
}

class Score {
  final int? id;
  final int userId;
  final int score;
  final int streak;
  final String date;

  Score({this.id, required this.userId, required this.score, required this.streak, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'user_id': userId, 'score': score, 'streak': streak, 'date': date};
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      score: map['score'] as int,
      streak: map['streak'] as int,
      date: map['date'] as String,
    );
  }
}
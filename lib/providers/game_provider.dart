import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class GameProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Random _random = Random();

  List<Word> _words = [];
  Word? _currentWord;
  String _displayWord = '';
  final Set<String> _guessedLetters = {};
  final Set<String> _wrongLetters = {};
  int _errors = 0;
  int _totalScore = 0;
  int _streak = 0;
  bool _isStudyMode = false;
  bool _gameOver = false;
  bool _wonLastWord = false;

  String get displayWord => _displayWord;
  Set<String> get guessedLetters => _guessedLetters;
  Set<String> get wrongLetters => _wrongLetters;
  int get errors => _errors;
  int get totalScore => _totalScore;
  int get streak => _streak;
  bool get isStudyMode => _isStudyMode;
  bool get gameOver => _gameOver;
  bool get wonLastWord => _wonLastWord;
  Word? get currentWord => _currentWord;

  Future<void> initGame({bool studyMode = false}) async {
    _isStudyMode = studyMode;
    _words = await _db.getAllWords();
    if (_words.isEmpty) return;

    _totalScore = 0;
    _streak = 0;
    _gameOver = false;
    _wonLastWord = false;
    _nextWord();
  }

  void _nextWord() {
    if (_words.isEmpty) return;
    _currentWord = _words[_random.nextInt(_words.length)];
    _guessedLetters.clear();
    _wrongLetters.clear();
    _errors = 0;
    _wonLastWord = false;
    _updateDisplay();
    notifyListeners();
  }

  void _updateDisplay() {
    if (_currentWord == null) return;
    _displayWord = _currentWord!.word.split('').map((char) {
      return _guessedLetters.contains(char) ? char : '_';
    }).join(' ');
  }

  void guessLetter(String letter) {
    if (_gameOver || _wonLastWord || _currentWord == null || _errors >= 6) return;
    if (_guessedLetters.contains(letter) || _wrongLetters.contains(letter)) return;

    if (_currentWord!.word.contains(letter)) {
      _guessedLetters.add(letter);
      _updateDisplay();
      if (!_displayWord.contains('_')) {
        _handleWordWin();
      }
    } else {
      _wrongLetters.add(letter);
      _errors++;
      if (_errors >= 6) {
        _handleWordLose();
      }
    }
    notifyListeners();
  }

  void _handleWordWin() {
    _wonLastWord = true;
    if (!_isStudyMode) {
      int wordScore = 500 - (_wrongLetters.length * 20);
      if (wordScore < 0) wordScore = 0;
      _totalScore += wordScore;
      _streak++;
    }
    notifyListeners();
  }

  void _handleWordLose() {
    if (!_isStudyMode) {
      _gameOver = true;
    }
    notifyListeners();
  }

  void continueAfterWin() {
    _nextWord();
  }

  void continueAfterLoseStudy() {
    if (_isStudyMode) {
      _nextWord();
    }
  }

  void restartGame() {
    initGame(studyMode: _isStudyMode);
  }

  void useHint(BuildContext context) {
    if (_currentWord == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pista: ${_currentWord!.description}', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepPurple,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> saveScore(int userId) async {
    if (_isStudyMode) return;
    Score score = Score(
      userId: userId,
      score: _totalScore,
      streak: _streak,
      date: DateTime.now().toIso8601String(),
    );
    await _db.addScore(score);
  }
}
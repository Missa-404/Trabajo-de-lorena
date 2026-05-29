import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static bool _isWeb = kIsWeb;

  Future<Database?> get database async {
    if (_isWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'hangman.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    batch.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        description TEXT NOT NULL,
        added_by INTEGER
      )
    ''');

    batch.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        streak INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    List<Map<String, dynamic>> defaultWords = [
      {'word': 'VARIABLE', 'description': 'Espacio en memoria para almacenar un valor que puede cambiar durante la ejecucion.'},
      {'word': 'FUNCION', 'description': 'Bloque de codigo reutilizable que realiza una tarea especifica.'},
      {'word': 'CLASE', 'description': 'Plantilla para crear objetos que define atributos y metodos.'},
      {'word': 'OBJETO', 'description': 'Instancia de una clase con estado y comportamiento propios.'},
      {'word': 'HERENCIA', 'description': 'Mecanismo para crear nuevas clases basadas en clases existentes.'},
      {'word': 'POLIMORFISMO', 'description': 'Capacidad de un metodo de comportarse de diferentes formas segun el objeto.'},
      {'word': 'ENCAPSULAMIENTO', 'description': 'Ocultamiento del estado interno de un objeto para proteger datos.'},
      {'word': 'ALGORITMO', 'description': 'Conjunto de pasos ordenados para resolver un problema.'},
      {'word': 'COMPILADOR', 'description': 'Programa que traduce codigo fuente a lenguaje maquina.'},
      {'word': 'DEPURACION', 'description': 'Proceso de encontrar y corregir errores en el codigo.'},
      {'word': 'ITERACION', 'description': 'Repeticion de un bloque de codigo un numero determinado de veces.'},
      {'word': 'RECURSIVIDAD', 'description': 'Tecnica donde una funcion se llama a si misma para resolver un problema.'},
      {'word': 'FRAMEWORK', 'description': 'Estructura de trabajo que facilita el desarrollo de aplicaciones.'},
      {'word': 'BIBLIOTECA', 'description': 'Coleccion de codigo reutilizable para realizar tareas comunes.'},
      {'word': 'API', 'description': 'Interfaz de Programacion de Aplicaciones para comunicar software.'},
      {'word': 'JSON', 'description': 'Formato ligero de intercambio de datos basado en texto.'},
      {'word': 'REST', 'description': 'Estilo de arquitectura para disenar servicios web escalables.'},
      {'word': 'MIDDLEWARE', 'description': 'Software que actua como puente entre sistemas o aplicaciones.'},
      {'word': 'BLOCKCHAIN', 'description': 'Cadena de bloques descentralizada para registrar transacciones.'},
      {'word': 'CLOUD', 'description': 'Computacion en la nube para acceder a recursos por internet.'},
    ];

    for (var w in defaultWords) {
      batch.insert('words', w);
    }

    await batch.commit();
  }

  // USUARIOS
  Future<int> registerUser(User user) async {
    if (_isWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      String userEntry = '${user.id ?? DateTime.now().millisecondsSinceEpoch}|${user.username}|${user.password}';
      users.add(userEntry);
      await prefs.setStringList('users', users);
      return 1;
    }
    final db = await database;
    return await db!.insert('users', user.toMap());
  }

  Future<User?> loginUser(String username, String password) async {
    if (_isWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      for (String u in users) {
        List<String> parts = u.split('|');
        if (parts.length == 3 && parts[1] == username && parts[2] == password) {
          return User(id: int.parse(parts[0]), username: parts[1], password: parts[2]);
        }
      }
      return null;
    }
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // PALABRAS
  Future<int> addWord(Word word) async {
    if (_isWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> words = prefs.getStringList('words') ?? [];
      int id = DateTime.now().millisecondsSinceEpoch;
      String wordEntry = '$id|${word.word}|${word.description}|${word.addedBy ?? 0}';
      words.add(wordEntry);
      await prefs.setStringList('words', words);
      return id;
    }
    final db = await database;
    return await db!.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords() async {
    if (_isWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> words = prefs.getStringList('words') ?? [];
      List<Word> result = [];
      for (String w in words) {
        List<String> parts = w.split('|');
        if (parts.length == 4) {
          result.add(Word(
            id: int.tryParse(parts[0]),
            word: parts[1],
            description: parts[2],
            addedBy: int.tryParse(parts[3]),
          ));
        }
      }
      if (result.isEmpty) {
        result = _getDefaultWords();
        await _saveDefaultWordsWeb(result);
      }
      return result;
    }
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query('words');
    return maps.map((w) => Word.fromMap(w)).toList();
  }

  List<Word> _getDefaultWords() {
    return [
      Word(word: 'VARIABLE', description: 'Espacio en memoria para almacenar un valor que puede cambiar durante la ejecucion.'),
      Word(word: 'FUNCION', description: 'Bloque de codigo reutilizable que realiza una tarea especifica.'),
      Word(word: 'CLASE', description: 'Plantilla para crear objetos que define atributos y metodos.'),
      Word(word: 'OBJETO', description: 'Instancia de una clase con estado y comportamiento propios.'),
      Word(word: 'HERENCIA', description: 'Mecanismo para crear nuevas clases basadas en clases existentes.'),
      Word(word: 'POLIMORFISMO', description: 'Capacidad de un metodo de comportarse de diferentes formas segun el objeto.'),
      Word(word: 'ENCAPSULAMIENTO', description: 'Ocultamiento del estado interno de un objeto para proteger datos.'),
      Word(word: 'ALGORITMO', description: 'Conjunto de pasos ordenados para resolver un problema.'),
      Word(word: 'COMPILADOR', description: 'Programa que traduce codigo fuente a lenguaje maquina.'),
      Word(word: 'DEPURACION', description: 'Proceso de encontrar y corregir errores en el codigo.'),
      Word(word: 'ITERACION', description: 'Repeticion de un bloque de codigo un numero determinado de veces.'),
      Word(word: 'RECURSIVIDAD', description: 'Tecnica donde una funcion se llama a si misma para resolver un problema.'),
      Word(word: 'FRAMEWORK', description: 'Estructura de trabajo que facilita el desarrollo de aplicaciones.'),
      Word(word: 'BIBLIOTECA', description: 'Coleccion de codigo reutilizable para realizar tareas comunes.'),
      Word(word: 'API', description: 'Interfaz de Programacion de Aplicaciones para comunicar software.'),
      Word(word: 'JSON', description: 'Formato ligero de intercambio de datos basado en texto.'),
      Word(word: 'REST', description: 'Estilo de arquitectura para disenar servicios web escalables.'),
      Word(word: 'MIDDLEWARE', description: 'Software que actua como puente entre sistemas o aplicaciones.'),
      Word(word: 'BLOCKCHAIN', description: 'Cadena de bloques descentralizada para registrar transacciones.'),
      Word(word: 'CLOUD', description: 'Computacion en la nube para acceder a recursos por internet.'),
    ];
  }

  Future<void> _saveDefaultWordsWeb(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> wordStrings = words.map((w) => '${w.id ?? DateTime.now().millisecondsSinceEpoch}|${w.word}|${w.description}|0').toList();
    await prefs.setStringList('words', wordStrings);
  }

  // PUNTUACIONES
  Future<int> addScore(Score score) async {
    if (_isWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> scores = prefs.getStringList('scores') ?? [];
      String scoreEntry = '${DateTime.now().millisecondsSinceEpoch}|${score.userId}|${score.score}|${score.streak}|${score.date}';
      scores.add(scoreEntry);
      await prefs.setStringList('scores', scores);
      return 1;
    }
    final db = await database;
    return await db!.insert('scores', score.toMap());
  }

  Future<List<Score>> getUserScores(int userId) async {
    if (_isWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> scores = prefs.getStringList('scores') ?? [];
      List<Score> result = [];
      for (String s in scores) {
        List<String> parts = s.split('|');
        if (parts.length == 5 && int.parse(parts[1]) == userId) {
          result.add(Score(
            id: int.parse(parts[0]),
            userId: int.parse(parts[1]),
            score: int.parse(parts[2]),
            streak: int.parse(parts[3]),
            date: parts[4],
          ));
        }
      }
      result.sort((a, b) => b.score.compareTo(a.score));
      return result;
    }
    final db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      'scores',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'score DESC',
    );
    return maps.map((s) => Score.fromMap(s)).toList();
  }
}
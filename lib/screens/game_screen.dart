import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/hangman_figure.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Consumer<GameProvider>(
          builder: (context, game, _) => Text(
            'Puntos: ${game.totalScore} | Racha: ${game.streak}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, _) {
              return Stack(
                children: [
                  // Contenido principal centrado
                  Column(
                    children: [
                      SizedBox(height: 60),
                      if (game.gameOver)
                        Expanded(child: _buildGameOverPanel(context, game))
                      else if (game.wonLastWord)
                        Expanded(child: _buildWinPanel(context, game))
                      else ...[
                        SizedBox(height: 20),
                        HangmanFigure(errors: game.errors),
                        SizedBox(height: 20),
                        Text(
                          game.displayWord,
                          style: TextStyle(fontSize: 32, letterSpacing: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Errores: ${game.errors}/6',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: _buildKeyboard(context, game),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ],
                  ),
                  // Botón de pista en esquina superior derecha
                  if (!game.gameOver && !game.wonLastWord)
                    Positioned(
                      top: 60,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () => game.useHint(context),
                        backgroundColor: Colors.yellow[700],
                        child: Icon(Icons.lightbulb, color: Colors.purple[900]),
                        elevation: 6,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context, GameProvider game) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: letters.split('').map((letter) {
        bool guessed = game.guessedLetters.contains(letter) || game.wrongLetters.contains(letter);
        bool isWrong = game.wrongLetters.contains(letter);
        return SizedBox(
          width: 40,
          height: 45,
          child: ElevatedButton(
            onPressed: guessed ? null : () => game.guessLetter(letter),
            style: ElevatedButton.styleFrom(
              backgroundColor: isWrong ? Colors.red[800] : (guessed ? Colors.green[800] : Colors.purple[700]),
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(letter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWinPanel(BuildContext context, GameProvider game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 80),
          SizedBox(height: 20),
          Text('PALABRA ADIVINADA!', style: TextStyle(fontSize: 28, color: Colors.green[400], fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text('Puntos esta palabra: ${500 - (game.wrongLetters.length * 20)}', style: TextStyle(fontSize: 20, color: Colors.white)),
          Text('Total acumulado: ${game.totalScore}', style: TextStyle(fontSize: 18, color: Colors.white70)),
          Text('Racha: ${game.streak}', style: TextStyle(fontSize: 18, color: Colors.yellow)),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => game.continueAfterWin(),
            child: Text('SIGUIENTE PALABRA', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverPanel(BuildContext context, GameProvider game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel, color: Colors.red[400], size: 80),
          SizedBox(height: 20),
          Text('GAME OVER', style: TextStyle(fontSize: 32, color: Colors.red[400], fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text('La palabra era: ${game.currentWord?.word}', style: TextStyle(fontSize: 20, color: Colors.white)),
          Text('Puntuacion final: ${game.totalScore}', style: TextStyle(fontSize: 18, color: Colors.white70)),
          Text('Racha maxima: ${game.streak}', style: TextStyle(fontSize: 18, color: Colors.yellow)),
          SizedBox(height: 30),
          FutureBuilder<int?>(
            future: AuthService().getCurrentUserId(),
            builder: (context, snapshot) {
              return Column(
                children: [
                  if (snapshot.data != null)
                    ElevatedButton(
                      onPressed: () async {
                        await game.saveScore(snapshot.data!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Partida guardada'), backgroundColor: Colors.green),
                        );
                        game.restartGame();
                        Navigator.pop(context);
                      },
                      child: Text('GUARDAR Y SALIR', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      game.restartGame();
                      Navigator.pop(context);
                    },
                    child: Text('JUGAR DE NUEVO', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
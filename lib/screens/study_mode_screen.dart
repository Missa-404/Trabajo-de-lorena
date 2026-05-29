import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/hangman_figure.dart';

class StudyModeScreen extends StatelessWidget {
  const StudyModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('MODO ESTUDIO', style: TextStyle(color: Colors.white, fontSize: 20)),
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
                      if (game.wonLastWord)
                        Expanded(child: _buildStudyWin(context, game))
                      else if (game.errors >= 6)
                        Expanded(child: _buildStudyLose(context, game))
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
                          'Errores: ${game.errors}/6 (Modo infinito)',
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
                  if (!game.wonLastWord && game.errors < 6)
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

  Widget _buildStudyWin(BuildContext context, GameProvider game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, color: Colors.green[400], size: 80),
          SizedBox(height: 20),
          Text('CORRECTO!', style: TextStyle(fontSize: 28, color: Colors.green[400], fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text('Sigues aprendiendo...', style: TextStyle(fontSize: 18, color: Colors.white70)),
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

  Widget _buildStudyLose(BuildContext context, GameProvider game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, color: Colors.orange[400], size: 80),
          SizedBox(height: 20),
          Text('LA PALABRA ERA:', style: TextStyle(fontSize: 22, color: Colors.white70)),
          Text('${game.currentWord?.word}', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('${game.currentWord?.description}', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white60)),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => game.continueAfterLoseStudy(),
            child: Text('CONTINUAR APRENDIENDO', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}
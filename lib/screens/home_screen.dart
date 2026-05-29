import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_background.dart';
import 'game_screen.dart';
import 'study_mode_screen.dart';
import 'add_word_screen.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    AuthService auth = AuthService();
    bool logged = await auth.isLoggedIn();
    String? user = await auth.getCurrentUsername();
    setState(() {
      isLoggedIn = logged;
      username = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code, size: 80, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'HANGMAN CODE',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                  ),
                  SizedBox(height: 10),
                  if (username != null)
                    Text('Bienvenido, $username', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  SizedBox(height: 40),
                  _buildMenuButton('JUGAR', Icons.play_arrow, () {
                    Provider.of<GameProvider>(context, listen: false).initGame();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen()));
                  }),
                  SizedBox(height: 15),
                  // MODO ESTUDIO SOLO PARA USUARIOS LOGUEADOS
                  if (isLoggedIn) ...[
                    _buildMenuButton('MODO ESTUDIO', Icons.school, () {
                      Provider.of<GameProvider>(context, listen: false).initGame(studyMode: true);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => StudyModeScreen()));
                    }),
                    SizedBox(height: 15),
                    _buildMenuButton('AGREGAR PALABRA', Icons.add, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddWordScreen()));
                    }),
                    SizedBox(height: 15),
                    _buildMenuButton('MIS RECORDS', Icons.emoji_events, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen()));
                    }),
                    SizedBox(height: 15),
                  ],
                  if (!isLoggedIn) ...[
                    _buildMenuButton('INICIAR SESION', Icons.login, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(onLogin: _checkAuth)));
                    }),
                    SizedBox(height: 15),
                    _buildMenuButton('REGISTRARSE', Icons.person_add, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                    }),
                  ] else ...[
                    _buildMenuButton('CERRAR SESION', Icons.logout, () async {
                      await AuthService().logout();
                      _checkAuth();
                    }),
                  ],
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[900]!.withOpacity(0.9),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: Colors.purple[400],
      ),
    );
  }
}
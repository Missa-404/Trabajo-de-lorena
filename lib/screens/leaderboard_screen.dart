import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/gradient_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Score> scores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() async {
    int? userId = await AuthService().getCurrentUserId();
    if (userId != null) {
      List<Score> data = await DatabaseService().getUserScores(userId);
      setState(() {
        scores = data;
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('MIS RECORDS', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.yellow, size: 40),
                    SizedBox(width: 10),
                    Text('TOP PUNTUACIONES', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 20),
                if (loading)
                  CircularProgressIndicator(color: Colors.white)
                else if (scores.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('Aun no tienes partidas registradas.\nJuega en modo normal para guardar tus records.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        Score s = scores[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: index == 0 ? Colors.yellow : Colors.white24, width: index == 0 ? 2 : 1),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: index == 0 ? Colors.yellow[700] : Colors.purple[700],
                              child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            title: Text('${s.score} puntos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text('Racha: ${s.streak} palabras', style: TextStyle(color: Colors.white70)),
                            trailing: Text(
                              s.date.substring(0, 10),
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/gradient_background.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({Key? key}) : super(key: key);

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _wordCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;

  void _saveWord() async {
    String word = _wordCtrl.text.trim().toUpperCase();
    String desc = _descCtrl.text.trim();

    if (word.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completa ambos campos'), backgroundColor: Colors.orange[900]),
      );
      return;
    }

    int? userId = await AuthService().getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesion'), backgroundColor: Colors.red[900]),
      );
      return;
    }

    setState(() => _loading = true);
    Word newWord = Word(word: word, description: desc, addedBy: userId);
    await DatabaseService().addWord(newWord);
    setState(() => _loading = false);

    _wordCtrl.clear();
    _descCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Palabra agregada exitosamente'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('AGREGAR PALABRA', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('NUEVO CONCEPTO', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 30),
                _buildTextField(_wordCtrl, 'Palabra (ej: VARIABLE)', Icons.text_fields),
                SizedBox(height: 15),
                _buildTextField(_descCtrl, 'Descripcion o definicion', Icons.description, maxLines: 4),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveWord,
                    child: _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('GUARDAR PALABRA', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/quiz_entry_model.dart';

class QuizPage extends StatefulWidget {
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _box = Hive.box<QuizEntryModel>('quiz_entries');
  final _answerController = TextEditingController();
  final _random = Random();
  QuizEntryModel? _current;
  String _resultMessage = '';
  Color _resultColor = Colors.transparent;

  void _loadNext() {
    final list = _box.values.toList();
    if (list.isEmpty) {
      setState(() => _current = null);
      return;
    }
    setState(() {
      _current = list[_random.nextInt(list.length)];
      _answerController.clear();
      _resultMessage = '';
      _resultColor = Colors.transparent;
    });
  }

  void _checkAnswer() {
    if (_current == null) return;

    final userAnswer = _answerController.text.trim();
    final correctAnswer = _current!.answer.trim();

    if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
      setState(() {
        _resultMessage = '正解です！';
        _resultColor = Colors.green;
      });
    } else {
      setState(() {
        _resultMessage = '不正解。正解は「$correctAnswer」です。';
        _resultColor = Colors.red;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNext();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('クイズ出題')),
      body: _current == null
          ? Center(child: Text('クイズが登録されていません'))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '問題 ${_current!.number}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _current!.question,
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      labelText: 'あなたの答え',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: Text('答え合わせ'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _resultMessage,
                    style: TextStyle(fontSize: 18, color: _resultColor),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNext,
                    child: Text('次の問題'),
                  ),
                ],
              ),
            ),
    );
  }
}

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
  final _random = Random();
  QuizEntryModel? _current;
  bool _showAnswer = false;

  void _loadNext() {
    final list = _box.values.toList();
    if (list.isEmpty) {
      setState(() => _current = null);
      return;
    }
    setState(() {
      _current = list[_random.nextInt(list.length)];
      _showAnswer = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('クイズ出題')),
      body: _current == null
        ? Center(child: Text('クイズが登録されていません'))
        : Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text('問題 ${_current!.number}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(_current!.question, style: TextStyle(fontSize: 22)),
              SizedBox(height: 30),
              if (_showAnswer) Text('答え: ${_current!.answer}', style: TextStyle(fontSize: 20, color: Colors.green)),
              SizedBox(height: 10),
              ElevatedButton(onPressed: () => setState(() => _showAnswer = true), child: Text('答えを表示')),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _loadNext, child: Text('次の問題')),
            ],
          ),
        ),
    );
  }
}

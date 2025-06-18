import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import 'models/entry_model.dart';
import 'main.dart'; // VideoPlayerPage を使うため

class QuizPage extends StatefulWidget {
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Box<EntryModel> _box = Hive.box<EntryModel>('entries');
  final Random _random = Random();
  AudioPlayer? _audioPlayer;
  EntryModel? _currentEntry;

  void _loadRandomEntry() {
    final entries = _box.values.toList();
    if (entries.isNotEmpty) {
      final randomEntry = entries[_random.nextInt(entries.length)];
      setState(() {
        _currentEntry = randomEntry;
      });
    }
  }

  Future<void> _playAudio(Uint8List bytes) async {
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();
    final blob = html.Blob([bytes], 'audio/mp3');
    final url = html.Url.createObjectUrlFromBlob(blob);
    await _audioPlayer!.setUrl(url);
    _audioPlayer!.play();
  }

  void _playVideo(Uint8List bytes) {
    final blob = html.Blob([bytes], 'video/mp4');
    final url = html.Url.createObjectUrlFromBlob(blob);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerPage(videoUrl: url)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRandomEntry();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEntry == null) {
      return Scaffold(
        appBar: AppBar(title: Text('クイズ')),
        body: Center(child: Text('登録データがありません')),
      );
    }

    final entry = _currentEntry!;
    return Scaffold(
      appBar: AppBar(title: Text('クイズ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('以下のマルチメディアの内容を確認してください:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            if (entry.image != null)
              Image.memory(entry.image!, height: 150),

            if (entry.audio != null)
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text("音楽再生: ${entry.audioName ?? ''}"),
                onPressed: () => _playAudio(entry.audio!),
              ),

            if (entry.video != null)
              ElevatedButton.icon(
                icon: Icon(Icons.movie),
                label: Text("動画再生: ${entry.videoName ?? ''}"),
                onPressed: () => _playVideo(entry.video!),
              ),

            SizedBox(height: 30),
            Text(
              'この登録の内容は何ですか？',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(entry.text, style: TextStyle(fontSize: 16, color: Colors.blue)),

            Spacer(),
            ElevatedButton(
              onPressed: _loadRandomEntry,
              child: Text('次の問題'),
            ),
          ],
        ),
      ),
    );
  }
}

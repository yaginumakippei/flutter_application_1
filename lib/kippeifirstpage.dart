import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'text_audio_database.dart'; // ← これを追加！

class KippeifirstPage extends StatefulWidget {
  @override
  _KippeifirstPageState createState() => _KippeifirstPageState();
}

class _KippeifirstPageState extends State<KippeifirstPage> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _savedText = "";
  bool _showMedia = false;
  Timer? _videoTimer;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory(); // DBから履歴読み込み
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _videoTimer?.cancel();
    super.dispose();
  }

  void _handleSave() async {
    final input = _controller.text;
    setState(() {
      _savedText = input;
      _showMedia = input == "高田健志";
    });

    String audioFile = "";

    if (_showMedia) {
      audioFile = 'audio/takada_kenshi_zanarkand.mp3';
      await _audioPlayer.play(AssetSource(audioFile));

      _videoTimer = Timer(Duration(seconds: 26), () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FullscreenVideoPage()),
        );
      });
    } else {
      await _audioPlayer.stop();
      _videoTimer?.cancel();
    }

    // データベースに保存
    await TextAudioDatabase.instance.insertEntry(input, audioFile);
    await _loadHistory(); // 保存後に履歴更新
  }

  Future<void> _loadHistory() async {
    final data = await TextAudioDatabase.instance.getAllEntries();
    setState(() {
      _history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ページ(1)")),
      backgroundColor: Colors.orange,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '文字を入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSave,
              child: Text('保存する'),
            ),
            SizedBox(height: 16),
            Text(
              '保存された文字: $_savedText',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            if (_showMedia) ...[
              Image.asset('images/takada.jpg', width: double.infinity, height: 200),
              SizedBox(height: 10),
              Text('🎵 音楽を再生中 🎵', style: TextStyle(color: Colors.white)),
            ],
            SizedBox(height: 20),
            Divider(color: Colors.white),
            Text('保存履歴', style: TextStyle(fontSize: 18, color: Colors.white)),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    title: Text(item['inputText'], style: TextStyle(color: Colors.white)),
                    subtitle: Text(item['audioFile'], style: TextStyle(color: Colors.white70)),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("最初のページに戻る", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

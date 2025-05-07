import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

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

    if (_showMedia) {
      await _audioPlayer.play(AssetSource('audio/takada_kenshi_zanarkand.mp3'));

      // 26秒後に全画面動画へ遷移
      _videoTimer = Timer(Duration(seconds: 26), () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FullscreenVideoPage()),
        );
      });
    } else {
      await _audioPlayer.stop();
      _videoTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ページ(1)")),
      backgroundColor: Colors.orange,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(height: 20),
            if (_showMedia) ...[
              Image.asset('images/takada.jpg', width: double.infinity, height: 200),
              SizedBox(height: 10),
              Text('🎵 音楽を再生中 🎵', style: TextStyle(color: Colors.white)),
            ],
            SizedBox(height: 30),
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

// 👇 ここから下が2つ目のコード（同じファイルに書く）

class FullscreenVideoPage extends StatefulWidget {
  @override
  _FullscreenVideoPageState createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('video/kenshi.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
                onTap: () => Navigator.pop(context), // タップで元の画面に戻る
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

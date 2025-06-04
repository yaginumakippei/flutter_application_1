import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '登録アプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _textController = TextEditingController();

  Uint8List? _imageBytes;
  Uint8List? _audioBytes;
  Uint8List? _videoBytes;

  String? _audioName;
  String? _videoName;

  AudioPlayer? _audioPlayer;

  List<Map<String, dynamic>> _entries = [];

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes!;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _audioBytes = result.files.single.bytes!;
        _audioName = result.files.single.name;
      });
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _videoBytes = result.files.single.bytes!;
        _videoName = result.files.single.name;
      });
    }
  }

  Future<void> _register() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _entries.add({
        'text': _textController.text,
        'image': _imageBytes,
        'audio': _audioBytes,
        'video': _videoBytes,
        'audioName': _audioName,
        'videoName': _videoName,
      });
      _textController.clear();
      _imageBytes = null;
      _audioBytes = null;
      _videoBytes = null;
      _audioName = null;
      _videoName = null;
    });
  }

  Future<void> _playAudio(Uint8List bytes) async {
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();

    final blob = html.Blob([bytes], 'audio/mp3');
    final url = html.Url.createObjectUrlFromBlob(blob);
    await _audioPlayer!.setUrl(url);
    _audioPlayer!.play();
  }

  void _playVideo(BuildContext context, Uint8List bytes) {
    final blob = html.Blob([bytes], 'video/mp4');
    final url = html.Url.createObjectUrlFromBlob(blob);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(videoUrl: url),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildEntry(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(item['text']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.memory(item['image'], height: 100),
              ),
            if (item['audio'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text("音楽再生: ${item['audioName']}"),
                  onPressed: () => _playAudio(item['audio']),
                ),
              ),
            if (item['video'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.movie),
                  label: Text("動画再生: ${item['videoName']}"),
                  onPressed: () => _playVideo(context, item['video']),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文字・画像・音楽・動画 登録'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: '文字を入力'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('画像を選択'),
            ),
            if (_imageBytes != null) Image.memory(_imageBytes!, height: 100),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickAudio,
              child: Text('音楽（MP3）を選択'),
            ),
            if (_audioName != null) Text('選択された音楽: $_audioName'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('動画（MP4）を選択'),
            ),
            if (_videoName != null) Text('選択された動画: $_videoName'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('登録'),
            ),
            SizedBox(height: 30),
            Divider(),
            Text('登録一覧', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._entries.map(_buildEntry).toList(),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('動画再生')),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

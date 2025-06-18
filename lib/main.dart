import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'models/entry_model.dart';
import 'quiz_page.dart'; // クイズページを追加でインポート

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(EntryModelAdapter());
  await Hive.openBox<EntryModel>('entries');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'マルチメディア登録',
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _textController = TextEditingController();
  Uint8List? _imageBytes;
  Uint8List? _audioBytes;
  Uint8List? _videoBytes;
  String? _audioName;
  String? _videoName;
  AudioPlayer? _audioPlayer;

  Box<EntryModel> get _box => Hive.box<EntryModel>('entries');

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _imageBytes = result.files.single.bytes!);
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _audioBytes = result.files.single.bytes!;
        _audioName = result.files.single.name;
      });
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp4']);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _videoBytes = result.files.single.bytes!;
        _videoName = result.files.single.name;
      });
    }
  }

  Future<void> _register() async {
    if (_textController.text.isEmpty) return;

    final entry = EntryModel(
      text: _textController.text,
      image: _imageBytes,
      audio: _audioBytes,
      video: _videoBytes,
      audioName: _audioName,
      videoName: _videoName,
    );

    await _box.add(entry);

    setState(() {
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

  Widget _buildEntry(EntryModel item, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(item.text),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.image != null) ...[
                SizedBox(height: 8),
                Image.memory(item.image!, height: 100),
              ],
              if (item.audio != null) ...[
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text("音楽再生: ${item.audioName ?? ''}"),
                  onPressed: () => _playAudio(item.audio!),
                ),
              ],
              if (item.video != null) ...[
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.movie),
                  label: Text("動画再生: ${item.videoName ?? ''}"),
                  onPressed: () => _playVideo(context, item.video!),
                ),
              ],
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.delete),
                label: Text("削除"),
                onPressed: () async {
                  await item.delete();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _textController.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('マルチメディア登録')),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<EntryModel> box, _) {
          final entries = box.values.toList();
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(labelText: '文字を入力'),
                ),
                SizedBox(height: 12),

                ElevatedButton(onPressed: _pickImage, child: Text('画像を選択')),
                if (_imageBytes != null) ...[
                  SizedBox(height: 8),
                  Image.memory(_imageBytes!, height: 100),
                ],
                SizedBox(height: 12),

                ElevatedButton(onPressed: _pickAudio, child: Text('音楽（MP3）を選択')),
                if (_audioName != null) ...[
                  SizedBox(height: 8),
                  Text('選択された音楽: $_audioName'),
                ],
                SizedBox(height: 12),

                ElevatedButton(onPressed: _pickVideo, child: Text('動画（MP4）を選択')),
                if (_videoName != null) ...[
                  SizedBox(height: 8),
                  Text('選択された動画: $_videoName'),
                ],
                SizedBox(height: 20),

                ElevatedButton(onPressed: _register, child: Text('登録')),
                SizedBox(height: 20),

                Divider(),
                Text("登録一覧", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...entries.asMap().entries.map((e) => _buildEntry(e.value, e.key)).toList(),

                SizedBox(height: 30),
                // クイズページへの遷移ボタン追加
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuizPage()),
                    );
                  },
                  child: Text('クイズを始める'),
                ),
              ],
            ),
          );
        },
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

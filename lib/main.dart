import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'models/entry_model.dart';
import 'models/quiz_entry_model.dart';
import 'quiz_page.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(EntryModelAdapter());
  Hive.registerAdapter(QuizEntryModelAdapter());
  await Hive.openBox<EntryModel>('entries');
  await Hive.openBox<QuizEntryModel>('quiz_entries');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'マルチメディア＋クイズ登録',
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

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  Box<EntryModel> get _entryBox => Hive.box<EntryModel>('entries');
  Box<QuizEntryModel> get _quizBox => Hive.box<QuizEntryModel>('quiz_entries');

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.single.bytes != null) setState(() => _imageBytes = res.files.single.bytes!);
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        _audioBytes = res.files.single.bytes!;
        _audioName = res.files.single.name;
      });
    }
  }

  Future<void> _pickVideo() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp4']);
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        _videoBytes = res.files.single.bytes!;
        _videoName = res.files.single.name;
      });
    }
  }

  Future<void> _registerEntry() async {
    if (_textController.text.isEmpty) return;
    final entry = EntryModel(
      text: _textController.text,
      image: _imageBytes,
      audio: _audioBytes,
      video: _videoBytes,
      audioName: _audioName,
      videoName: _videoName,
    );
    await _entryBox.add(entry);
    setState(() {
      _textController.clear();
      _imageBytes = null;
      _audioBytes = null;
      _videoBytes = null;
      _audioName = null;
      _videoName = null;
    });
  }

  Future<void> _registerQuizEntry() async {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) return;
    final entry = QuizEntryModel(
      question: _questionController.text,
      answer: _answerController.text,
      number: _quizBox.length + 1,
    );
    await _quizBox.add(entry);
    setState(() {
      _questionController.clear();
      _answerController.clear();
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
      MaterialPageRoute(builder: (_) => VideoPlayerPage(videoUrl: url)),
    );
  }

  Widget _buildEntryTile(EntryModel item, int i) {
    return Card(
      child: ListTile(
        title: Text(item.text),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.image != null) Image.memory(item.image!, height: 80),
          if (item.audio != null)
            ElevatedButton.icon(icon: Icon(Icons.play_arrow), label: Text("音声: ${item.audioName}"), onPressed: () => _playAudio(item.audio!)),
          if (item.video != null)
            ElevatedButton.icon(icon: Icon(Icons.movie), label: Text("動画: ${item.videoName}"), onPressed: () => _playVideo(context, item.video!)),
        ]),
        trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => item.delete().then((_) => setState(() {}))),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _audioPlayer?.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entryBox.values.toList();
    final quizEntries = _quizBox.values.toList();
    return Scaffold(
      appBar: AppBar(title: Text('クイズ・保存')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [

          // マルチメディア登録セクション
          TextField(controller: _textController, decoration: InputDecoration(labelText: '本文テキスト')),
          SizedBox(height: 6),
          ElevatedButton(onPressed: _pickImage, child: Text('画像選択')),
          if (_imageBytes != null) Image.memory(_imageBytes!, height: 80),
          ElevatedButton(onPressed: _pickAudio, child: Text('音声選択')),
          if (_audioName != null) Text(_audioName!),
          ElevatedButton(onPressed: _pickVideo, child: Text('動画選択')),
          if (_videoName != null) Text(_videoName!),
          ElevatedButton(onPressed: _registerEntry, child: Text('登録')),
          Divider(),

          // 登録済マルチメディア一覧
          Text('登録済マルチメディア一覧', style: TextStyle(fontWeight: FontWeight.bold)),
          ...entries.asMap().entries.map((e) => _buildEntryTile(e.value, e.key)).toList(),
          Divider(),

          // 見出しクイズ登録セクション
          Text('クイズ 問題・答え 登録', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _questionController, decoration: InputDecoration(labelText: '問題文')),
          SizedBox(height: 6),
          TextField(controller: _answerController, decoration: InputDecoration(labelText: '答え')),
          SizedBox(height: 6),
          ElevatedButton(onPressed: _registerQuizEntry, child: Text('登録（クイズ）')),
          Divider(),

          // 登録済クイズ一覧
          Text('登録済クイズ一覧', style: TextStyle(fontWeight: FontWeight.bold)),
          ...quizEntries.map((q) => ListTile(leading: Text('Q${q.number}'), title: Text(q.question), subtitle: Text('答え: ${q.answer}'))).toList(),
          Divider(),

          // クイズ開始ボタン
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage())),
            child: Text('クイズを始める'),
          ),
        ]),
      ),
    );
  }
}

// VideoPlayerPage は既存コードをそのまま使えます
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
      ..initialize().then((_) { setState(() {}); _controller.play(); });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('動画再生')),
      body: Center(
        child: _controller.value.isInitialized
          ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
          : CircularProgressIndicator()
      ),
    );
  }
}

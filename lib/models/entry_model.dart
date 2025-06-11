import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'entry_model.g.dart';

@HiveType(typeId: 0)
class EntryModel extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  Uint8List? image;

  @HiveField(2)
  Uint8List? audio;

  @HiveField(3)
  Uint8List? video;

  @HiveField(4)
  String? audioName;

  @HiveField(5)
  String? videoName;

  EntryModel({
    required this.text,
    this.image,
    this.audio,
    this.video,
    this.audioName,
    this.videoName,
  });
}

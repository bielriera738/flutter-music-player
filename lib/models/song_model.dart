import 'dart:typed_data';

class Song {
  final String id;
  final String name;
  final String fileUrl;
  final String? title;
  final String? artist;
  final String? album;
  final Duration? duration;
  final Uint8List? albumArt;

  Song({
    required this.id,
    required this.name,
    required this.fileUrl,
    this.title,
    this.artist,
    this.album,
    this.duration,
    this.albumArt,
  });

  @override
  String toString() =>
      'Song(id: $id, name: $name, title: $title, artist: $artist, album: $album, duration: $duration)';
}

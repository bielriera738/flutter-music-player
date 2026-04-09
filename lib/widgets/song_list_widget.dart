import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/music_provider.dart';

class SongListWidget extends StatelessWidget {
  final List<Song> songs;

  const SongListWidget({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final isCurrentSong = musicProvider.currentIndex == index;

            return ListTile(
              leading: isCurrentSong
                  ? const Icon(Icons.music_note, color: Colors.deepPurple)
                  : const Icon(Icons.music_note_outlined),
              title: Text(
                song.title ?? song.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight:
                      isCurrentSong ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentSong ? Colors.deepPurple : Colors.black,
                ),
              ),
              subtitle: Text(
                song.artist ?? 'Artista desconocido',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                await musicProvider.playSongByIndex(index);
              },
              selected: isCurrentSong,
            );
          },
        );
      },
    );
  }
}

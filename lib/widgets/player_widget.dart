import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/music_provider.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Metadatos
              if (musicProvider.currentSong != null) ...[
                Text(
                  musicProvider.currentSong!.title ??
                      musicProvider.currentSong!.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  musicProvider.currentSong!.artist ?? 'Artista desconocido',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Barra de progreso
                StreamBuilder<Duration>(
                  stream: musicProvider.audioService.positionStream,
                  builder: (context, positionSnapshot) {
                    return StreamBuilder<Duration?>(
                      stream: musicProvider.audioService.durationStream,
                      builder: (context, durationSnapshot) {
                        final position =
                            positionSnapshot.data ?? Duration.zero;
                        final duration =
                            durationSnapshot.data ?? Duration.zero;

                        return Column(
                          children: [
                            Slider(
                              value: duration.inMilliseconds > 0
                                  ? position.inMilliseconds
                                      .toDouble()
                                      .clamp(0.0,
                                          duration.inMilliseconds.toDouble())
                                  : 0,
                              max: duration.inMilliseconds.toDouble(),
                              onChanged: (value) async {
                                await musicProvider.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ] else
                const Text('Selecciona una canción'),

              // Botones de control
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Anterior
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 32,
                    onPressed: () async {
                      await musicProvider.previousSong();
                    },
                  ),

                  const SizedBox(width: 16),

                  // Play/Pausa
                  FloatingActionButton(
                    heroTag: 'player_fab',
                    onPressed: () async {
                      if (musicProvider.isPlaying) {
                        await musicProvider.pauseSong();
                      } else {
                        if (musicProvider.currentSong == null) {
                          await musicProvider.playSongByIndex(0);
                        } else {
                          await musicProvider.resumeSong();
                        }
                      }
                    },
                    child: Icon(
                      musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Siguiente
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 32,
                    onPressed: () async {
                      await musicProvider.nextSong();
                    },
                  ),
                ],
              ),
              
              // Botones secundarios (Shuffle y Repetición)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  IconButton(
                    icon: const Icon(Icons.shuffle),
                    iconSize: 24,
                    color: musicProvider.isShuffleEnabled
                        ? Colors.deepPurple
                        : Colors.grey,
                    onPressed: () {
                      musicProvider.toggleShuffle();
                    },
                  ),
                  
                  // Repetición
                  IconButton(
                    icon: const Icon(Icons.repeat),
                    iconSize: 24,
                    color: musicProvider.isRepeatEnabled
                        ? Colors.deepPurple
                        : Colors.grey,
                    onPressed: () {
                      musicProvider.toggleRepeat();
                    },
                  ),
                ],
              ),
              
              // Control de volumen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.volume_down, size: 20),
                    Expanded(
                      child: Slider(
                        value: musicProvider.volume,
                        onChanged: (value) async {
                          await musicProvider.setVolume(value);
                        },
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                    const Icon(Icons.volume_up, size: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}


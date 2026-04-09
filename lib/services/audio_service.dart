import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  /// Reproduce una canción desde una URL
  Future<void> playSong(Song song) async {
    try {
      await _audioPlayer.setUrl(song.fileUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  /// Pausa la reproducción
  Future<void> pauseSong() async {
    await _audioPlayer.pause();
  }

  /// Reanuda la reproducción
  Future<void> resumeSong() async {
    await _audioPlayer.play();
  }

  /// Detiene completamente la reproducción
  Future<void> stopSong() async {
    await _audioPlayer.stop();
  }

  /// Ajusta el volumen (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  /// Salta a una posición específica
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Obtiene la duración de la canción actual
  Duration? get duration => _audioPlayer.duration;

  /// Stream de posición actual
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Stream de estado del reproductor
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Stream de duración
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Libera recursos
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

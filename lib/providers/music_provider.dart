import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../services/supabase_service.dart';
import '../services/audio_service.dart';

class MusicProvider extends ChangeNotifier {
  final supabaseService = SupabaseService();
  final audioService = AudioService();

  List<Song> _songs = [];
  Song? _currentSong;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffleEnabled = false;
  bool _isRepeatEnabled = false;
  double _volume = 1.0;

  // Getters
  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isRepeatEnabled => _isRepeatEnabled;
  double get volume => _volume;

  MusicProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await supabaseService.initialize();
    await loadSongs();
  }

  /// Carga las canciones desde Supabase
  Future<void> loadSongs() async {
    _songs = await supabaseService.getSongs();
    notifyListeners();
  }

  /// Reproduce una canción por índice
  Future<void> playSongByIndex(int index) async {
    if (index < 0 || index >= _songs.length) return;
    
    _currentIndex = index;
    _currentSong = _songs[index];
    _isPlaying = true;
    
    await audioService.playSong(_currentSong!);
    notifyListeners();
  }

  /// Pausa la canción actual
  Future<void> pauseSong() async {
    await audioService.pauseSong();
    _isPlaying = false;
    notifyListeners();
  }

  /// Reanuda la reproducción
  Future<void> resumeSong() async {
    await audioService.resumeSong();
    _isPlaying = true;
    notifyListeners();
  }

  /// Siguiente canción
  Future<void> nextSong() async {
    if (_isShuffleEnabled) {
      // Canción aleatoria
      final randomIndex = _getRandomIndex();
      await playSongByIndex(randomIndex);
    } else {
      if (_currentIndex < _songs.length - 1) {
        await playSongByIndex(_currentIndex + 1);
      }
    }
  }

  /// Canción anterior
  Future<void> previousSong() async {
    if (_currentIndex > 0) {
      await playSongByIndex(_currentIndex - 1);
    }
  }

  /// Alterna shuffle
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    notifyListeners();
  }

  /// Alterna repetición
  void toggleRepeat() {
    _isRepeatEnabled = !_isRepeatEnabled;
    notifyListeners();
  }

  /// Establece el volumen
  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    await audioService.setVolume(_volume);
    notifyListeners();
  }

  /// Salta a una posición específica
  Future<void> seek(Duration position) async {
    await audioService.seek(position);
    notifyListeners();
  }

  /// Obtiene un índice aleatorio diferente al actual
  int _getRandomIndex() {
    if (_songs.isEmpty) return 0;
    int randomIndex = _currentIndex;
    
    if (_songs.length > 1) {
      while (randomIndex == _currentIndex) {
        randomIndex = (randomIndex + DateTime.now().millisecond) % _songs.length;
      }
    }
    
    return randomIndex;
  }

  @override
  Future<void> dispose() async {
    await audioService.dispose();
    super.dispose();
  }
}

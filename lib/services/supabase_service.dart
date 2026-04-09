import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/song_model.dart';

class SupabaseService {
  late final SupabaseClient _supabase;
  final String _bucketName = dotenv.env['SUPABASE_BUCKET_NAME'] ?? 'audio';

  Future<void> initialize() async {
    _supabase = Supabase.instance.client;
  }

  /// Obtiene la lista de canciones del bucket de Supabase
  Future<List<Song>> getSongs() async {
    try {
      final files = await _supabase.storage.from(_bucketName).list();
      
      List<Song> songs = [];
      
      for (var file in files) {
        if (file.name.toLowerCase().endsWith('.mp3')) {
          final fileUrl = _supabase.storage
              .from(_bucketName)
              .getPublicUrl(file.name);
          
          songs.add(
            Song(
              id: file.id,
              name: file.name,
              fileUrl: fileUrl,
              title: file.name.replaceAll('.mp3', ''),
            ),
          );
        }
      }
      
      return songs;
    } catch (e) {
      print('Error loading songs: $e');
      return [];
    }
  }

  /// Obtiene una URL firmada de Supabase (opcional)
  Future<String> getSignedUrl(String fileName, {int expiresIn = 3600}) async {
    try {
      final url = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(fileName, expiresIn);
      return url;
    } catch (e) {
      print('Error creating signed URL: $e');
      return '';
    }
  }
}

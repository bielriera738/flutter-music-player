import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_list_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/search_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<MusicProvider>();
      await provider.loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproductor de Música'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, _) {
          if (musicProvider.songs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Lista de canciones o búsqueda
              Expanded(
                flex: 2,
                child: _isSearching
                    ? SearchWidget(songs: musicProvider.songs)
                    : SongListWidget(songs: musicProvider.songs),
              ),
              
              // Divisor
              Container(
                height: 1,
                color: Colors.grey[300],
              ),

              // Reproductor
              const Expanded(
                flex: 1,
                child: PlayerWidget(),
              ),
            ],
          );
        },
      ),
    );
  }
}


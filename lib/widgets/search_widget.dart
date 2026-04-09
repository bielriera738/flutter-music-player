import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/music_provider.dart';

class SearchWidget extends StatefulWidget {
  final List<Song> songs;

  const SearchWidget({super.key, required this.songs});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController _searchController;
  List<Song> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredSongs = widget.songs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSongs = widget.songs;
      });
    } else {
      setState(() {
        _filteredSongs = widget.songs
            .where((song) =>
                (song.title ?? song.name)
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (song.artist ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (song.album ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Busca canciones...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSongs('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: _filterSongs,
          ),
        ),

        // Lista de canciones filtradas
        Expanded(
          child: _filteredSongs.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'No hay canciones'
                        : 'No se encontraron canciones',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Consumer<MusicProvider>(
                  builder: (context, musicProvider, _) {
                    return ListView.builder(
                      itemCount: _filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = _filteredSongs[index];
                        final isCurrentSong =
                            musicProvider.currentSong?.id == song.id;

                        return ListTile(
                          leading: isCurrentSong
                              ? const Icon(Icons.music_note,
                                  color: Colors.deepPurple)
                              : const Icon(Icons.music_note_outlined),
                          title: Text(
                            song.title ?? song.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isCurrentSong
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentSong
                                  ? Colors.deepPurple
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            song.artist ?? 'Artista desconocido',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            // Encontrar el índice en la lista original
                            final originalIndex =
                                widget.songs.indexOf(song);
                            await musicProvider
                                .playSongByIndex(originalIndex);
                          },
                          selected: isCurrentSong,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

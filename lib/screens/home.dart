// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/providers/player_providers.dart';
import 'package:music_player/providers/theme_provider.dart'; // Import theme provider
import 'package:music_player/widgets/bottom_player.dart';
import 'package:music_player/widgets/mini_player_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

final audioQuery = OnAudioQuery();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<SongModel> songs = [];
  List<SongModel> filteredSongs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredSongs = songs;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      filteredSongs =
          songs.where((song) {
            final titleMatch = song.title.toLowerCase().contains(query);
            final artistMatch = (song.artist ?? '').toLowerCase().contains(
              query,
            );
            return titleMatch || artistMatch;
          }).toList();
    });
  }

  Future<void> fetchSongs() async {
    final oldPermissions = await Permission.storage.request();
    final newPermissions = await Permission.audio.request();
    if (oldPermissions.isGranted || newPermissions.isGranted) {
      final fetchedSongs = await audioQuery.querySongs();
      if (mounted) {
        setState(() {
          songs = fetchedSongs;
          // Sort by dateAdded in descending order (newest first)
          songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
          filteredSongs = songs;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Allow storage permission"),
            action: SnackBarAction(
              label: "Open Settings",
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final themeMode = ref.watch(themeModeProvider); // Removed unused variable
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  autofocus: true,
                )
                : const Text('Music Player'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _isSearching = false;
                  filteredSongs = songs;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Consumer(
              builder: (context, ref, _) {
                final currentThemeMode = ref.watch(themeModeProvider);
                final platformBrightness =
                    MediaQuery.of(context).platformBrightness;
                bool isCurrentlyDark;
                if (currentThemeMode == ThemeModeOption.system) {
                  isCurrentlyDark = platformBrightness == Brightness.dark;
                } else {
                  isCurrentlyDark = currentThemeMode == ThemeModeOption.dark;
                }
                return Icon(
                  isCurrentlyDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                );
              },
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSongs,
        child:
            songs.isEmpty
                ? LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('No Songs... Pull down to refresh'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
                : filteredSongs.isEmpty && _isSearching
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No songs found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
                : Stack(
                  children: [
                    Positioned.fill(
                      child: Scrollbar(
                        thickness: 5.0,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                leading: QueryArtworkWidget(
                                  id: song.id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(
                                      Icons.music_note,
                                      size: 30.0,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                  ),
                                  artworkHeight: 50.0,
                                  artworkWidth: 50.0,
                                  artworkFit: BoxFit.cover,
                                  artworkBorder: BorderRadius.circular(8.0),
                                  artworkClipBehavior: Clip.antiAlias,
                                ),
                                title: Text(
                                  song.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  song.artist ?? 'Unknown Artist',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () async {
                                  // Find the index in the original songs list
                                  final originalIndex = songs.indexWhere(
                                    (s) => s.id == song.id,
                                  );
                                  ref
                                      .read(currentSongIndexProvider.notifier)
                                      .state = originalIndex;
                                  final playerInstance = ref.read(
                                    audioPlayerProvider,
                                  );
                                  if (song.uri != null) {
                                    try {
                                      await playerInstance.setAudioSource(
                                        AudioSource.uri(Uri.parse(song.uri!)),
                                      );
                                      await playerInstance.play();
                                    } catch (e) {
                                      // print("Error playing song: $e");
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error playing ${song.title}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: MiniPlayerWidget(
        songs: songs,
        onTap: () {
          if (ref.watch(currentSongIndexProvider) != null && songs.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return BottomPlayer(songs: songs);
              },
            );
          }
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}

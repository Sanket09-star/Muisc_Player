// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/providers/player_providers.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayerWidget extends ConsumerWidget {
  final List<SongModel> songs;
  final VoidCallback onTap;

  const MiniPlayerWidget({super.key, required this.songs, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongIndex = ref.watch(currentSongIndexProvider);

    if (currentSongIndex == null || songs.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentSong = songs[currentSongIndex];
    final player = ref.watch(audioPlayerProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            QueryArtworkWidget(
              id: currentSong.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const Icon(
                Icons.music_note,
                color: Colors.white,
              ),
              artworkHeight: 40.0,
              artworkWidth: 40.0,
              artworkFit: BoxFit.cover,
              artworkBorder: BorderRadius.circular(4.0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong.artist ?? 'Unknown Artist',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (playing ?? false) {
                    return const Icon(Icons.pause, color: Colors.white);
                  } else if (processingState != ProcessingState.completed) {
                    return const Icon(Icons.play_arrow, color: Colors.white);
                  } else {
                    return const Icon(Icons.play_arrow, color: Colors.white);
                  }
                },
              ),
              onPressed: () {
                if (player.playing) {
                  player.pause();
                } else {
                  player.play();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
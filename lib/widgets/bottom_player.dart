// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/providers/player_providers.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:math'; // For shuffle

class BottomPlayer extends ConsumerStatefulWidget {
  final List<SongModel> songs;

  const BottomPlayer({super.key, required this.songs});

  @override
  ConsumerState<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends ConsumerState<BottomPlayer> {
  bool _isShuffleModeEnabled = false;
  // LoopMode _loopMode = LoopMode.off; // Removed loop mode
  int? _lastSourcedIndex;

  String format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void handlePlayButton() {
    final player = ref.read(audioPlayerProvider);
    if (player.playing) {
      player.pause();
    } else {
      if (player.processingState == ProcessingState.completed) {
        player.seek(Duration.zero).then((_) => player.play());
      } else {
        player.play();
      }
    }
  }

  void playNext() {
    final currentIndex = ref.read(currentSongIndexProvider);

    if (currentIndex == null || widget.songs.isEmpty) return;

    int nextIndex;
    if (_isShuffleModeEnabled) {
      if (widget.songs.length <= 1) {
        // if (widget.songs.isNotEmpty && _loopMode == LoopMode.all) { // Removed loop mode check
        //   nextIndex = 0;
        // } else {
        return; // If only one song or no song, and not looping, do nothing
        // }
      } else {
        nextIndex = Random().nextInt(widget.songs.length);
        while (nextIndex == currentIndex) {
          nextIndex = Random().nextInt(widget.songs.length);
        }
      }
    } else {
      if (currentIndex < widget.songs.length - 1) {
        nextIndex = currentIndex + 1;
        // } else if (_loopMode == LoopMode.all && widget.songs.isNotEmpty) { // Removed loop mode check
        //   nextIndex = 0;
      } else {
        // Reached end of playlist, stop or handle as per non-looping behavior (currently return)
        return;
      }
    }
    ref.read(currentSongIndexProvider.notifier).state = nextIndex;
  }

  void playPrevious() {
    final currentIndex = ref.read(currentSongIndexProvider);

    if (currentIndex == null || widget.songs.isEmpty) return;

    int prevIndex;
    if (_isShuffleModeEnabled) {
      if (widget.songs.length <= 1) {
        // if (widget.songs.isNotEmpty && _loopMode == LoopMode.all) { // Removed loop mode check
        //   prevIndex = 0;
        // } else {
        return; // If only one song or no song, and not looping, do nothing
        // }
      } else {
        prevIndex = Random().nextInt(widget.songs.length);
        while (prevIndex == currentIndex) {
          prevIndex = Random().nextInt(widget.songs.length);
        }
      }
    } else {
      if (currentIndex > 0) {
        prevIndex = currentIndex - 1;
        // } else if (_loopMode == LoopMode.all && widget.songs.isNotEmpty) { // Removed loop mode check
        //   prevIndex = widget.songs.length - 1;
      } else {
        // Reached beginning of playlist, stop or handle as per non-looping behavior (currently return)
        return;
      }
    }
    ref.read(currentSongIndexProvider.notifier).state = prevIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final playerHeight = screenHeight * 0.6;

    return Consumer(
      builder: (context, ref, child) {
        final index = ref.watch(currentSongIndexProvider);
        final player = ref.watch(audioPlayerProvider);
        final positionStream = player.positionStream;
        final duration = player.duration ?? Duration.zero;

        player.processingStateStream.listen((processingState) {
          if (processingState == ProcessingState.completed) {
            // if (_loopMode == LoopMode.one) { // Removed loop mode check
            //   player.seek(Duration.zero);
            //   player.play();
            // } else {
            playNext(); // Always play next when completed if not looping one song
            // }
          }
        });

        if (index != null && index != _lastSourcedIndex) {
          if (index >= 0 && index < widget.songs.length) {
            final songToPlay = widget.songs[index];
            if (songToPlay.uri != null && songToPlay.uri!.isNotEmpty) {
              player
                  .setAudioSource(AudioSource.uri(Uri.parse(songToPlay.uri!)))
                  .then((_) {
                    _lastSourcedIndex = index;
                  })
                  .catchError((error) {
                    //print("Error setting audio source: $error");
                    _lastSourcedIndex = index;
                  });
            } else {
              _lastSourcedIndex = index;
            }
          }
        }

        if (index == null || widget.songs.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentSong = widget.songs[index];

        return Container(
          height: playerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: playerHeight * 0.35,
                  height: playerHeight * 0.35,
                  child: QueryArtworkWidget(
                    id: currentSong.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: playerHeight * 0.18,
                        color: Colors.white70,
                      ),
                    ),
                    artworkFit: BoxFit.cover,
                    artworkBorder: BorderRadius.circular(playerHeight * 0.175),
                    artworkClipBehavior: Clip.antiAlias,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      currentSong.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentSong.artist ?? 'Unknown Artist',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<Duration>(
                  stream: positionStream,
                  builder: (context, snapshot) {
                    final currentPosition = snapshot.data ?? Duration.zero;
                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14.0,
                            ),
                            activeTrackColor:
                                Theme.of(context).colorScheme.primary,
                            inactiveTrackColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.3),
                            thumbColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Slider(
                            value: currentPosition.inMilliseconds
                                .toDouble()
                                .clamp(0.0, duration.inMilliseconds.toDouble()),
                            min: 0.0,
                            max:
                                duration.inMilliseconds.toDouble() > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1.0,
                            onChanged: (value) {
                              player.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                format(currentPosition),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                format(duration),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color:
                              _isShuffleModeEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(179),
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isShuffleModeEnabled = !_isShuffleModeEnabled;
                          });
                          player.setShuffleModeEnabled(_isShuffleModeEnabled);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          size: 36,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: playPrevious,
                      ),
                      IconButton(
                        icon: StreamBuilder<PlayerState>(
                          stream: player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing;
                            if (playing ?? false) {
                              return Icon(
                                Icons.pause_circle_filled,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            } else if (processingState !=
                                ProcessingState.completed) {
                              return Icon(
                                Icons.play_circle_filled,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            } else {
                              return Icon(
                                Icons.replay_circle_filled,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            }
                          },
                        ),
                        iconSize: 60.0,
                        onPressed: handlePlayButton,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          size: 36,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: playNext,
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     _loopMode == LoopMode.off
                      //         ? Icons.repeat
                      //         : _loopMode == LoopMode.one
                      //             ? Icons.repeat_one_outlined // Changed for consistency
                      //             : Icons.repeat_on_outlined, // Icon for LoopMode.all
                      //     color: _loopMode != LoopMode.off
                      //         ? Theme.of(context).colorScheme.primary
                      //         : Theme.of(context)
                      //             .colorScheme
                      //             .onSurface
                      //             .withOpacity(0.7),
                      //     size: 24,
                      //   ),
                      //   onPressed: () {
                      //     if (_loopMode == LoopMode.off) {
                      //       // Transition to LoopMode.one
                      //       player.setLoopMode(LoopMode.one);
                      //       // setState(() => _loopMode = LoopMode.one);
                      //     } else if (_loopMode == LoopMode.one) {
                      //       // Transition to LoopMode.all (manual handling via playNext/Prev)
                      //       // We still set player's loop mode to off, as 'all' is manually handled.
                      //       player.setLoopMode(LoopMode.off);
                      //       // setState(() => _loopMode = LoopMode.all);
                      //     } else { // _loopMode == LoopMode.all
                      //       // Transition to LoopMode.off
                      //       player.setLoopMode(LoopMode.off);
                      //       // setState(() => _loopMode = LoopMode.off);
                      //     }
                      //   },
                      // ),
                      // Placeholder to maintain layout if needed, or adjust spacing
                      SizedBox(
                        width: 48,
                      ), // Same width as IconButton (icon 24 + padding)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

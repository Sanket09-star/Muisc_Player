import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
final audioPlayerProvider = Provider<AudioPlayer>((ref){
  final player = AudioPlayer();
  ref.onDispose(()=>player.dispose());
  return player;
});

final currentSongIndexProvider = StateProvider<int?>((ref) => null);
final positionStreamIndexProvider = StreamProvider<Duration>((ref){
  final player = ref.watch(audioPlayerProvider);
  return player.positionStream;
});

final durationProvider = Provider<Duration?>((ref){
  final player = ref.watch(audioPlayerProvider);
  return player.duration;
});
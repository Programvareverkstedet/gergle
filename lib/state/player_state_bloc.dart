import 'dart:developer' show log;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gergle/api/events.dart';
import 'package:gergle/state/player_state.dart';

class PlayerStateBloc extends Bloc<Event, PlayerState?> {
  PlayerStateBloc() : super(null) {
    on<InitialPlayerState>((event, emit) {
      emit(event.playerState);
    });

    on <ClearPlayerState>((event, emit) {
      emit(null);
    });

    on<PropertyChangedEvent>((event, emit) {
      // print('Received event: $event');
      if (state == null) {
        log('Received event before initial state');
        return;
      }

      switch (event) {
        case PlaylistChange playlistChange:
          final newState = state!.copyWith(playlist: playlistChange.playlist);
          emit(newState);
          break;
        case LoopPlaylistChange loopPlaylistChange:
          final newState =
              state!.copyWith(isLooping: loopPlaylistChange.isLooping);
          emit(newState);
          break;
        case PercentPositionChange percentPositionChange:
          final newState = state!.copyWith(
            currentPercentPosition:
                percentPositionChange.currentPercentPosition,
          );
          emit(newState);
          break;
        case VolumeChange volumeChange:
          final newState = state!.copyWith(volume: volumeChange.volume);
          emit(newState);
          break;
        case DurationChange durationChange:
          final newState = state!.copyWith(duration: durationChange.duration);
          emit(newState);
          break;
        case PauseChange pauseChange:
          final newState = state!.copyWith(isPlaying: !pauseChange.isPaused);
          emit(newState);
          break;
        case MuteChange muteChange:
          final newState = state!.copyWith(isMuted: muteChange.isMuted);
          emit(newState);
          break;
        case TrackListChange trackListChange:
          final newState =
              state!.copyWith(subtitleTracks: trackListChange.tracks);
          emit(newState);
          break;
        case DemuxerCacheStateChange demuxerCacheStateChange:
          final newState = state!.copyWith(
            cachedTimestamp: demuxerCacheStateChange.cachedTimestamp,
          );
          emit(newState);
          break;
        case PausedForCacheChange pausedForCacheChange:
          final newState = state!.copyWith(
            isPausedForCache: pausedForCacheChange.isPausedForCache,
          );
          emit(newState);
          break;
      }
    });
  }
}

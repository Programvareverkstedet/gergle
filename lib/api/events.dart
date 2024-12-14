// TODO: handle typing and deserialization of events
import 'package:flutter/foundation.dart';

import '../state/player_state.dart';

// NOTE: see DEFAULT_PROPERTY_SUBSCRIPTIONS in the websocket API source for greg-ng.

@immutable
sealed class Event {
  const Event();
}

@immutable
class ClearPlayerState extends Event {
  const ClearPlayerState() : super();
}

@immutable
class InitialPlayerState extends Event {
  final PlayerState playerState;

  const InitialPlayerState(this.playerState) : super();

  factory InitialPlayerState.fromJson(dynamic json) {
    return InitialPlayerState(PlayerState.fromJson(json));
  }
}

@immutable
sealed class PropertyChangedEvent extends Event {
  final bool local;

  const PropertyChangedEvent({this.local = false}) : super();
}

@immutable
class PlaylistChange extends PropertyChangedEvent {
  final Playlist playlist;

  const PlaylistChange(this.playlist, { super.local }) : super();

  factory PlaylistChange.fromJson(dynamic json) {
    return PlaylistChange(
      (json as List).map((e) => PlaylistItem.fromJson(e)).toList(),
    );
  }
}

@immutable
class LoopPlaylistChange extends PropertyChangedEvent {
  final bool isLooping;

  const LoopPlaylistChange(this.isLooping, { super.local }) : super();

  factory LoopPlaylistChange.fromJson(dynamic json) {
    return LoopPlaylistChange(json == "inf");
  }
}

@immutable
class PercentPositionChange extends PropertyChangedEvent {
  final double currentPercentPosition;

  const PercentPositionChange(this.currentPercentPosition, { super.local }) : super();

  factory PercentPositionChange.fromJson(dynamic json) {
    return PercentPositionChange(json ?? 0.0);
  }
}

@immutable
class VolumeChange extends PropertyChangedEvent {
  final double volume;

  const VolumeChange(this.volume, { super.local }) : super();

  factory VolumeChange.fromJson(dynamic json) {
    return VolumeChange(json);
  }
}

@immutable
class DurationChange extends PropertyChangedEvent {
  final Duration duration;

  const DurationChange(this.duration, { super.local }) : super();

  factory DurationChange.fromJson(dynamic json) {
    return DurationChange(Duration(milliseconds: ((json ?? 0.0) * 1000).round()));
  }
}

@immutable
class PauseChange extends PropertyChangedEvent {
  final bool isPaused;

  const PauseChange(this.isPaused, { super.local }) : super();

  factory PauseChange.fromJson(dynamic json) {
    return PauseChange(json as bool);
  }
}

@immutable
class MuteChange extends PropertyChangedEvent {
  final bool isMuted;

  const MuteChange(this.isMuted, { super.local }) : super();

  factory MuteChange.fromJson(dynamic json) {
    return MuteChange(json as bool);
  }
}

@immutable
class TrackListChange extends PropertyChangedEvent {
  final List<SubtitleTrack> tracks;

  const TrackListChange(this.tracks, { super.local }) : super();

  factory TrackListChange.fromJson(dynamic json) {
    final trackList = json as List;
    trackList.retainWhere((e) => e is Map && e['type'] == 'sub');
    return TrackListChange(
      trackList.map((e) => SubtitleTrack.fromJson(e)).toList(),
    );
  }
}

@immutable
class DemuxerCacheStateChange extends PropertyChangedEvent {
  final double cachedTimestamp;

  const DemuxerCacheStateChange(this.cachedTimestamp, { super.local }) : super();

  factory DemuxerCacheStateChange.fromJson(dynamic json) {
    final demuxerCacheState = json as Map?;
    final cachedTimestamp =
        demuxerCacheState != null ? demuxerCacheState['cache-end'] ?? 0.0 : 0.0;
    return DemuxerCacheStateChange(cachedTimestamp);
  }
}

@immutable
class PausedForCacheChange extends PropertyChangedEvent {
  final bool isPausedForCache;

  const PausedForCacheChange(this.isPausedForCache, { super.local }) : super();

  factory PausedForCacheChange.fromJson(dynamic json) {
    return PausedForCacheChange(json as bool? ?? false);
  }
}

// @immutable
// class ChapterListChange extends PropertyChangedEvent {
//   final List<Chapter> chapters;

//   ChapterListChange(this.chapters);

//   factory ChapterListChange.fromJson(dynamic json) {
//     return ChapterListChange(
//       (json as List).map((e) => Chapter.fromJson(e)).toList(),
//     );
//   }
// }

Event? parseEvent(dynamic value) {
  if (value is String) {
    return null;
  }

  if (value is Map && value.containsKey('property-change')) {
    final propertyChange = value['property-change'];
    switch (propertyChange['name']) {
      case 'playlist':
        return PlaylistChange.fromJson(propertyChange['data']);
      case 'loop-playlist':
        return LoopPlaylistChange.fromJson(propertyChange['data']);
      case 'percent-pos':
        return PercentPositionChange.fromJson(propertyChange['data']);
      case 'volume':
        return VolumeChange.fromJson(propertyChange['data']);
      case 'duration':
        return DurationChange.fromJson(propertyChange['data']);
      case 'pause':
        return PauseChange.fromJson(propertyChange['data']);
      case 'mute':
        return MuteChange.fromJson(propertyChange['data']);
      case 'track-list':
        return TrackListChange.fromJson(propertyChange['data']);
      case 'demuxer-cache-state':
        return DemuxerCacheStateChange.fromJson(propertyChange['data']);
      case 'paused-for-cache':
        return PausedForCacheChange.fromJson(propertyChange['data']);

      // "chapter-list",
      // "paused-for-cache",

      default:
        return null;
    }
  }

  return null;
}

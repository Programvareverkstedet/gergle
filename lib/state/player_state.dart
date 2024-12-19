import 'package:flutter/material.dart';

@immutable
class PlayerState {
  final List<Chapter> chapters;
  final List<SubtitleTrack> subtitleTracks;
  final Playlist playlist;
  final String currentTrack;
  final bool isLooping;
  final bool isMuted;
  final bool isPlaying;
  final bool isPausedForCache;
  final double? cachedTimestamp;
  final Duration duration;
  final double volume;
  final double? currentPercentPosition;

  const PlayerState({
    required this.cachedTimestamp,
    required this.chapters,
    required this.currentPercentPosition,
    required this.currentTrack,
    required this.duration,
    required this.isLooping,
    required this.isMuted,
    required this.isPlaying,
    required this.isPausedForCache,
    required this.playlist,
    required this.subtitleTracks,
    required this.volume,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      cachedTimestamp: json['cached_timestamp'],
      chapters:
          (json['chapters'] as List).map((e) => Chapter.fromJson(e)).toList(),
      currentPercentPosition: json['current_percent_pos'],
      currentTrack: json['current_track'],
      duration: Duration(milliseconds: (json['duration'] * 1000).round()),
      isLooping: json['is_looping'],
      isMuted: json['is_muted'],
      isPlaying: json['is_playing'],
      isPausedForCache: json['is_paused_for_cache'],
      playlist: (json['playlist'] as List)
          .map((e) => PlaylistItem.fromJson(e))
          .toList(),
      subtitleTracks: (json['tracks'] as List)
          .map((e) => SubtitleTrack.fromJson(e))
          .toList(),
      volume: json['volume'],
    );
  }

  PlayerState copyWith({
    List<Chapter>? chapters,
    List<SubtitleTrack>? subtitleTracks,
    Playlist? playlist,
    String? currentTrack,
    bool? isLooping,
    bool? isMuted,
    bool? isPlaying,
    bool? isPausedForCache,
    double? cachedTimestamp,
    double? currentPercentPosition,
    Duration? duration,
    double? volume,
  }) {
    return PlayerState(
      cachedTimestamp: cachedTimestamp ?? this.cachedTimestamp,
      chapters: chapters ?? this.chapters,
      currentPercentPosition:
          currentPercentPosition ?? this.currentPercentPosition,
      currentTrack: currentTrack ?? this.currentTrack,
      duration: duration ?? this.duration,
      isLooping: isLooping ?? this.isLooping,
      isMuted: isMuted ?? this.isMuted,
      isPlaying: isPlaying ?? this.isPlaying,
      isPausedForCache: isPausedForCache ?? this.isPausedForCache,
      playlist: playlist ?? this.playlist,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      volume: volume ?? this.volume,
    );
  }
}

typedef Playlist = List<PlaylistItem>;

@immutable
class PlaylistItem {
  final bool current;
  final String filename;
  final int id;
  final String? title;

  const PlaylistItem({
    required this.current,
    required this.filename,
    required this.id,
    required this.title,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      current: json['current'] ?? false,
      filename: json['filename'],
      id: json['id'],
      title: json['title'],
    );
  }
}

@immutable
class Chapter {
  final String title;
  final double time;

  const Chapter({
    required this.title,
    required this.time,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'],
      time: json['time'],
    );
  }
}

@immutable
class SubtitleTrack {
  final int id;
  final String title;
  final String? lang;

  const SubtitleTrack({
    required this.id,
    required this.title,
    required this.lang,
  });

  factory SubtitleTrack.fromJson(Map<String, dynamic> json) {
    return SubtitleTrack(
      id: json['id'],
      title: json['title'],
      lang: json['lang'],
    );
  }
}

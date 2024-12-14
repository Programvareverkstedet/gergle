import 'dart:convert';

sealed class ConnectionEvent {}

class Connect extends ConnectionEvent {
  final String uri;

  Connect(this.uri);
}

class Disconnect extends ConnectionEvent {}

class Command extends ConnectionEvent {
  final String type;
  final Map<String, dynamic> value;

  Command({
    required this.type,
    required this.value,
  });

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = Map.from(value);
    result['type'] = type;
    return result;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory Command.subscribe(String property) {
    return Command(
      type: 'subscribe',
      value: {
        'property': property,
      },
    );
  }

  factory Command.unsubscribeAll() {
    return Command(
      type: 'unsubscribe_all',
      value: {},
    );
  }

  factory Command.load(String url) {
    return Command(
      type: 'load',
      value: {
        'url': url,
      },
    );
  }

  factory Command.togglePlayback() {
    return Command(
      type: 'toggle_playback',
      value: {},
    );
  }

  factory Command.volume(double volume) {
    return Command(
      type: 'volume',
      value: {
        'volume': volume,
      },
    );
  }

  factory Command.time(double time) {
    return Command(
      type: 'time',
      value: {
        'time': time,
      },
    );
  }

  factory Command.playlistNext() {
    return Command(
      type: 'playlist_next',
      value: {},
    );
  }

  factory Command.playlistPrevious() {
    return Command(
      type: 'playlist_previous',
      value: {},
    );
  }

  factory Command.playlistGoto(int position) {
    return Command(
      type: 'playlist_goto',
      value: {
        'position': position,
      },
    );
  }

  factory Command.playlistClear() {
    return Command(
      type: 'playlist_clear',
      value: {},
    );
  }

  factory Command.playlistRemove(int position) {
    return Command(
      type: 'playlist_remove',
      value: {
        'position': position,
      },
    );
  }

  factory Command.playlistMove(int from, int to) {
    return Command(
      type: 'playlist_move',
      value: {
        'from': from,
        'to': to,
      },
    );
  }

  factory Command.shuffle() {
    return Command(
      type: 'shuffle',
      value: {},
    );
  }

  factory Command.setLooping(bool value) {
    return Command(
      type: 'set_looping',
      value: {
        'value': value,
      },
    );
  }
}
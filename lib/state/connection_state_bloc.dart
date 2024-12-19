import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:gergle/api/commands.dart';
import 'package:gergle/api/events.dart';
import 'package:gergle/state/player_state_bloc.dart';

@immutable
sealed class PlayerConnectionState {}

@immutable
class Disconnected extends PlayerConnectionState {}

@immutable
class Connecting extends PlayerConnectionState {
  final String uri;

  Connecting(this.uri);
}

@immutable
class Connected extends PlayerConnectionState {
  final String uri;
  final WebSocketChannel channel;

  Connected(this.uri, this.channel);
}

@immutable
class ConnectionError extends PlayerConnectionState {
  final String message;
  final String uri;

  ConnectionError(this.message, this.uri);
}

class ConnectionStateBloc
    extends Bloc<PlayerConnectionEvent, PlayerConnectionState> {
  final PlayerStateBloc playerStateBloc;

  ConnectionStateBloc(this.playerStateBloc) : super(Disconnected()) {
    on<Connect>((event, emit) async {
      if (state is Connected) {
        if ((state as Connected).uri == event.uri) {
          log('Already connected to ${event.uri}');
          return;
        } else {
          // Clear connection, and reconnect
          (state as Connected).channel.sink.close();
          playerStateBloc.add(const ClearPlayerState());
        }
      }

      emit(Connecting(event.uri));

      final channel = WebSocketChannel.connect(
        Uri.parse(event.uri),
      );

      try {
        await channel.ready;
      } on WebSocketChannelException catch (e) {
        late final String message;
        if (e.inner is WebSocketException) {
          message = (e.inner as WebSocketException).message;
        } else {
          message = e.message ?? e.toString();
        }

        log('Error connecting to ${event.uri}: $message');
        emit(ConnectionError(message, event.uri));
        return;
      }

      channel.stream.listen(
        (event) {
          final jsonData = jsonDecode(event as String);
          if (jsonData is Map) {
            switch (jsonData['type']) {
              case 'initial_state':
                playerStateBloc.add(
                  InitialPlayerState.fromJson(jsonData['value']),
                );
                break;
              case 'event':
                final event = parseEvent(jsonData['value']);
                if (event == null) {
                  log('Unknown event: ${jsonData['value']}');
                } else {
                  log('Handling event: $event');
                  playerStateBloc.add(event);
                }
                break;
              default:
                log('Unknown message type: ${jsonData['type']}');
                log('Message: $jsonData');
                break;
            }
          }
        },
        onError: (error, stackTrace) {
          log('Error: $error');
          log('Stack trace: $stackTrace');
        },
        onDone: () {
          add(Disconnect());
          log('Connection closed, reconnecting...');
          add(Connect(event.uri));
        },
      );

      emit(Connected(event.uri, channel));
    });

    on<Disconnect>((event, emit) {
      if (state is! Connected) {
        log('Cannot disconnect when not connected');
        return;
      }
      (state as Connected).channel.sink.close();
      playerStateBloc.add(const ClearPlayerState());
      emit(Disconnected());
    });

    on<Command>((event, emit) {
      if (state is! Connected) {
        log('Cannot send command when not connected');
        return;
      }

      (state as Connected).channel.sink.add(event.toJsonString());
    });
  }
}

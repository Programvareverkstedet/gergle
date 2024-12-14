import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/commands.dart';
import '../api/events.dart';
import 'player_state_bloc.dart';

class ConnectionStateBloc extends Bloc<ConnectionEvent, WebSocketChannel?> {
  final PlayerStateBloc playerStateBloc;

  String? _uri;
  WebSocketChannel? _channel;

  ConnectionStateBloc(this.playerStateBloc) : super(null) {

    on<Connect>((event, emit) {
      if (_channel != null && _uri == event.uri) {
        log('Already connected to ${event.uri}');
        return;
      } else if (_channel != null) {
        // Clear connection, and reconnect
        state?.sink.close();
        playerStateBloc.add(const ClearPlayerState());
        emit(null);
      }

      _uri = event.uri;

      _channel = WebSocketChannel.connect(
        Uri.parse(event.uri),
      );

      _channel!.stream.listen(
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
        onError: (error) {
          log('Error: $error');
        },
        onDone: () {
          add(Disconnect());
          log('Connection closed, reconnecting...');
          add(Connect(_uri!));
        },
      );

      emit(_channel);
    });

    on<Disconnect>((event, emit) {
      _uri = null;
      state?.sink.close(0, 'Disconnecting');
      playerStateBloc.add(const ClearPlayerState());
      emit(null);
    });

    on<Command>((event, emit) {
      if (_channel == null) {
        log('Cannot send command when not connected');
        return;
      }

      _channel!.sink.add(event.toJsonString());
    });
  }
}

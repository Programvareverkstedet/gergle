import 'dart:math' show max;
import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gergle/api/commands.dart';
import 'package:gergle/api/events.dart';
import 'state/connection_state_bloc.dart';
import 'state/player_state_bloc.dart';
import 'state/player_state.dart';

class PlayerUi extends StatelessWidget {
  PlayerUi({
    super.key,
  });

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<PlayerStateBloc, PlayerState?>(
          builder: (context, state) {
            if (state == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final playerState = state;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, i) =>
                        _buildPlaylistTile(context, playerState, i),
                    itemCount: playerState.playlist.length,
                    onReorder: (from, to) {
                      BlocProvider.of<ConnectionStateBloc>(context).add(
                        Command.playlistMove(from, to),
                      );

                      if (from < to) {
                        to -= 1;
                      }
                      final item = playerState.playlist.removeAt(from);
                      playerState.playlist.insert(to, item);

                      BlocProvider.of<PlayerStateBloc>(context).add(
                          PlaylistChange(playerState.playlist, local: true));
                    },
                  ),
                ),
                _buildInputBar(context, playerState),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<PlayerStateBloc, PlayerState?>(
        builder: (context, state) {
          if (state == null) {
            return const SizedBox.shrink();
          }

          return _buildBottomBar(context, state);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Gergle'),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        DropdownMenu(
          leadingIcon: const Icon(Icons.storage),
          dropdownMenuEntries: const <DropdownMenuEntry<String?>>[
            DropdownMenuEntry(
              label: 'Georg',
              value: 'wss://georg.pvv.ntnu.no/ws',
            ),
            DropdownMenuEntry(
              label: 'Brzeczyszczykiewicz',
              value: 'wss://brzeczyszczykiewicz.pvv.ntnu.no/ws',
            ),
            if (kDebugMode) ...[
              DropdownMenuEntry(
                label: 'Local 8009',
                value: 'ws://localhost:8009/ws',
              ),
            ],
            DropdownMenuEntry(
              value: null,
              label: 'Custom...',
            ),
          ],
          onSelected: (value) async {
            final connectionStateBloc =
                BlocProvider.of<ConnectionStateBloc>(context);
            value ??= await _askForServerUriMenu(context);

            if (value == null) {
              return;
            }

            connectionStateBloc.add(Connect(value));
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            throw UnimplementedError();
          },
        ),
        if (kDebugMode) ...[
          const SizedBox(width: 50),
        ],
      ],
    );
  }

  Future<String?> _askForServerUriMenu(BuildContext context) async {
    final textController = TextEditingController();

    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter server URI'),
            content: TextField(
              decoration: const InputDecoration(
                labelText: 'Server URI',
              ),
              controller: textController,
              onSubmitted: (value) {
                Navigator.of(context).pop(value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final value = textController.text;
                  textController.dispose();
                  Navigator.of(context).pop(value);
                },
                child: const Text('Connect'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, PlayerState playerState) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Add to playlist',
              filled: true,
              fillColor: const Color.fromARGB(10, 0, 0, 0),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onSubmitted: (value) {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.load(value));
              _textController.clear();
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            BlocProvider.of<ConnectionStateBloc>(context)
                .add(Command.load(_textController.text));
            _textController.clear();
          },
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          onPressed: () {
            // TODO: popup menu for adding multiple links
            throw UnimplementedError();
          },
        ),
      ],
    );
  }

  ListTile _buildPlaylistTile(
    BuildContext context,
    PlayerState playerState,
    int i,
  ) {
    final item = playerState.playlist[i];
    return ListTile(
      key: ValueKey(item.id),
      title: Text(item.title ?? item.filename),
      subtitle: Text(item.filename),
      selected: item.current,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${i + 1}.",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: playerState.isPlaying && item.current
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistGoto(i));
            },
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: item.filename)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            color: Colors.redAccent,
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistRemove(i));
            },
          ),
        ],
      ),
    );
  }

  static String formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  Widget _buildBottomBar(BuildContext context, PlayerState playerState) {
    // NOTE: slider throws if the value is over 100, so 99.999 is used to avoid
    //       hitting the limit with floating point errors.
    double cachedPercent = playerState.cachedTimestamp != null
        ? ((playerState.cachedTimestamp! /
                max(playerState.duration.inMilliseconds, 0.00000000000001)) *
            1000 *
            99.999)
        : 0.0;
    if (cachedPercent > 100) {
      cachedPercent = 0;
    }

    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistPrevious());
            },
          ),
          IconButton(
            icon: playerState.isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.togglePlayback());
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistNext());
            },
          ),
          Expanded(
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Text(
                  formatTime(
                    Duration(
                      milliseconds: playerState.currentPercentPosition != null
                          ? (playerState.currentPercentPosition! *
                                  playerState.duration.inMilliseconds *
                                  0.01)
                              .round()
                          : 0,
                    ),
                  ),
                ),
                // Text(((playerState.currentPercentPosition ?? 0.0) *
                //         0.01 *
                //         playerState.duration)
                //     .toString()),
                Expanded(
                  flex: 5,
                  child: Slider(
                    value: playerState.currentPercentPosition ?? 0,
                    max: 100.0,
                    secondaryTrackValue: cachedPercent,
                    onChanged: (value) {
                      log('Setting time to $value');
                      BlocProvider.of<ConnectionStateBloc>(context)
                          .add(Command.time(value));
                    },
                  ),
                ),
                Text(formatTime(playerState.duration)),
                // TODO: set minimum width for this slider
                Expanded(
                  flex: 1,
                  child: Slider(
                    value: playerState.volume,
                    max: 130.0,
                    secondaryTrackValue: 100.0,
                    onChanged: (value) {
                      BlocProvider.of<ConnectionStateBloc>(context)
                          .add(Command.volume(value));
                    },
                  ),
                ),
                Text('${playerState.volume.round()}%'),
              ],
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.subtitles),
          //   onPressed: () {
          //     throw UnimplementedError();
          //   },
          // ),
          PopupMenuButton(
            icon: const Icon(Icons.subtitles),
            enabled: playerState.subtitleTracks.isNotEmpty,
            itemBuilder: (context) {
              return playerState.subtitleTracks
                  .map((track) => PopupMenuItem(
                        value: track.id,
                        child: Text(track.title),
                      ))
                  .toList();
            },
            onSelected: (value) {
              // TODO: add command for changing subtitle track
              throw UnimplementedError();
            },
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            isSelected: playerState.isLooping,
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.setLooping(!playerState.isLooping));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.shuffle());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistClear());
            },
          ),
        ],
      ),
    );
  }
}

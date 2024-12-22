import 'dart:math' show max;
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gergle/api/commands.dart';
import 'package:gergle/state/connection_state_bloc.dart';
import 'package:gergle/player_ui/main.dart';

class PlayerUIBottomBar extends StatelessWidget {
  const PlayerUIBottomBar({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surfaceBright,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: 'Skip to previous track',
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistPrevious());
            },
          ),
          playerBlocBuilder(
            buildProps: (p) => [p.isPlaying],
            builder: (context, playerState) {
              return IconButton(
                icon: (playerState.isPlaying)
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                tooltip: (playerState.isPlaying) ? 'Pause' : 'Play',
                onPressed: () {
                  BlocProvider.of<ConnectionStateBloc>(context)
                      .add(Command.togglePlayback());
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Skip to next track',
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.playlistNext());
            },
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraint) {
                return Row(
                  children: [
                    playerBlocBuilder(
                      buildProps: (p) => [p.currentPercentPosition, p.duration],
                      builder: (context, playerState) {
                        final milliseconds =
                            (playerState.currentPercentPosition! *
                                    playerState.duration.inMilliseconds *
                                    0.01)
                                .round();
                        return Text(
                          formatTime(
                            Duration(milliseconds: milliseconds),
                          ),
                        );
                      },
                    ),
                    Flexible(
                      flex: 5,
                      child: playerBlocBuilder(
                        buildProps: (p) => [
                          p.cachedTimestamp,
                          p.currentPercentPosition,
                          p.duration,
                        ],
                        builder: (context, playerState) {
                          // NOTE: slider throws if the value is over 100, so 99.999 is used to avoid
                          //       hitting the limit with floating point errors.
                          double cachedPercent = playerState.cachedTimestamp !=
                                  null
                              ? ((playerState.cachedTimestamp! /
                                      max(playerState.duration.inMilliseconds,
                                          0.00000000000001)) *
                                  1000 *
                                  99.999)
                              : 0.0;
                          if (0 < cachedPercent || cachedPercent > 100) {
                            cachedPercent = 0;
                          }
                          return Slider(
                            value: playerState.currentPercentPosition ?? 0,
                            max: 100.0,
                            secondaryTrackValue: cachedPercent,
                            onChanged: (value) {
                              log('Setting time to $value');
                              BlocProvider.of<ConnectionStateBloc>(context)
                                  .add(Command.time(value));
                            },
                          );
                        },
                      ),
                    ),
                    playerBlocBuilder(
                      buildProps: (p) => [p.duration],
                      builder: (context, playerState) =>
                          Text(formatTime(playerState.duration)),
                    ),
                    SizedBox(
                      width: max(constraint.maxWidth / 6, 200),
                      child: playerBlocBuilder(
                        buildProps: (p) => [p.volume],
                        builder: (context, playerState) => Slider(
                          value: playerState.volume,
                          max: 130.0,
                          secondaryTrackValue: 100.0,
                          onChanged: (value) {
                            BlocProvider.of<ConnectionStateBloc>(context)
                                .add(Command.volume(value));
                          },
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          playerBlocBuilder(
            buildProps: (p) => [p.subtitleTracks],
            builder: (context, playerState) => PopupMenuButton(
              icon: const Icon(Icons.subtitles),
              tooltip: 'Select subtitle track',
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
          ),
          playerBlocBuilder(
            buildProps: (p) => [p.isLooping],
            builder: (context, playerState) => IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: 'Toggle playlist looping',
              isSelected: playerState.isLooping,
              onPressed: () {
                BlocProvider.of<ConnectionStateBloc>(context)
                    .add(Command.setLooping(!playerState.isLooping));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle playlist',
            onPressed: () {
              BlocProvider.of<ConnectionStateBloc>(context)
                  .add(Command.shuffle());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear playlist',
            color: Colors.redAccent,
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

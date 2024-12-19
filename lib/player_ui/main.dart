import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gergle/api/commands.dart';
import 'package:gergle/player_ui/app_bar.dart';
import 'package:gergle/player_ui/body.dart';
import 'package:gergle/player_ui/bottom_bar.dart';
import 'package:gergle/state/connection_state_bloc.dart';
import 'package:gergle/state/player_state.dart';
import 'package:gergle/state/player_state_bloc.dart';

Widget playerBlocBuilder({
  required List<dynamic> Function(PlayerState) buildProps,
  required Widget Function(BuildContext, PlayerState) builder,
}) {
  return BlocBuilder<PlayerStateBloc, PlayerState?>(
    buildWhen: (previous, current) =>
        (previous == null) ||
        (current != null && (buildProps(previous) != buildProps(current))),
    builder: (context, playerState) {
      if (playerState == null) {
        return const Placeholder();
      }
      return builder(context, playerState);
    },
  );
}

class PlayerUi extends StatelessWidget {
  const PlayerUi({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionStateBloc, PlayerConnectionState>(
      builder: (context, state) {
        if (state is Disconnected) {
          return Scaffold(
            appBar: PlayerUIAppBar.appbar(context),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Disconnected'),
                  // TODO: add more here
                ],
              ),
            ),
          );
        }

        if (state is Connecting) {
          return Scaffold(
            appBar: PlayerUIAppBar.appbar(context),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Connecting...'),
                ],
              ),
            ),
          );
        }

        if (state is ConnectionError) {
          final pictureList = [
            'assets/images/cry1.gif',
            'assets/images/cry2.gif',
          ];
          final pictureUri = pictureList[Random().nextInt(pictureList.length)];
          return Scaffold(
            appBar: PlayerUIAppBar.appbar(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Connection error: ${state.message}'),
                  const SizedBox(height: 20),
                  Image.asset(
                    pictureUri,
                    scale: 0.7,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        BlocProvider.of<ConnectionStateBloc>(context)
                            .add(Connect(state.uri)),
                    child: const Text('Reconnect'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: PlayerUIAppBar.appbar(context),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Flex(direction: Axis.horizontal, children: [
                  const Expanded(flex: 1, child: SizedBox.expand()),
                  Expanded(
                    flex: 3,
                    child: PlayerUIBody(),
                  ),
                  const Expanded(flex: 1, child: SizedBox.expand()),
                ]),
              ),
              Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.surfaceDim,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 10,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/miku_cube.png',
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),
                  const Expanded(flex: 3, child: SizedBox.expand()),
                  const Expanded(flex: 1, child: SizedBox.expand()),
                ],
              ),
              Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/dance2.gif',
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  const Expanded(flex: 3, child: SizedBox.expand()),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/dance1.webp',
                      alignment: Alignment.bottomCenter,
                    ),
                  )
                ],
              ),
            ],
          ),
          bottomNavigationBar: const PlayerUIBottomBar(),
        );
      },
    );
  }
}

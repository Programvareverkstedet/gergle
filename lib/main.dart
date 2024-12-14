import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'state/connection_state_bloc.dart';
import 'state/player_state_bloc.dart';
import 'player_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerStateBloc playerStateBloc = PlayerStateBloc();
    final ConnectionStateBloc connectionStateBloc =
        ConnectionStateBloc(playerStateBloc);

    return MaterialApp(
      title: 'Gergle',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => connectionStateBloc),
          BlocProvider(create: (_) => playerStateBloc),
        ],
        child: PlayerUi(),
      ),
    );
  }
}
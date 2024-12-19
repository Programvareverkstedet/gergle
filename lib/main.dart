import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'player_ui/main.dart';
import 'state/connection_state_bloc.dart';
import 'state/player_state_bloc.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF86CECB),
          onPrimary: Color.fromARGB(255, 200, 255, 252),
          secondary: Color.fromARGB(255, 19, 122, 127),
          onSecondary: Color.fromARGB(255, 25, 157, 164),
          error: Colors.red,
          onError: Colors.redAccent,
          surface: Color.fromARGB(255, 12, 72, 75),
          surfaceBright: Color.fromARGB(255, 19, 122, 127),
          surfaceDim: Color.fromARGB(255, 8, 53, 54),
          onSurface: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => connectionStateBloc),
          BlocProvider(create: (_) => playerStateBloc),
        ],
        child: const PlayerUi(),
      ),
    );
  }
}

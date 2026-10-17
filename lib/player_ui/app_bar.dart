import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gergle/api/commands.dart';
import 'package:gergle/player_ui/main.dart';
import 'package:gergle/preferences.dart';
import 'package:gergle/servers.dart';
import 'package:gergle/state/connection_state_bloc.dart';
import 'package:gergle/state/player_state_bloc.dart';

class PlayerUIAppBar {
  static AppBar appbar(BuildContext context) {
    return AppBar(
      title: const Text('Gergle'),
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.copy_all),
          tooltip: 'Copy playlist to clipboard',
          onPressed: () {
            final state = BlocProvider.of<PlayerStateBloc>(context).state;
            if (state != null) {
              final uris = state.playlist
                  .map((e) => e.filename)
                  .where((f) => f != '/tmp/the_man.png')
                  .join('\n');
              if (uris.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: uris));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied playlist to clipboard'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
              }
            }
          },
        ),
        DropdownMenu(
          leadingIcon: const Icon(Icons.storage),
          initialSelection: _selectedKnownServerUri(context),
          dropdownMenuEntries: <DropdownMenuEntry<String?>>[
            for (final server in knownServers)
              DropdownMenuEntry(label: server.label, value: server.uri),
            const DropdownMenuEntry(
              value: null,
              label: 'Custom...',
            ),
          ],
          onSelected: (value) async {
            final connectionStateBloc =
                BlocProvider.of<ConnectionStateBloc>(context);
            value ??= await _askForServerUriMenu(context);

            if (value == null) {
              // TODO: restore previous selection.
              return;
            }

            await saveLastServerUri(value);
            connectionStateBloc.add(Connect(value));
          },
        ),
        playerBlocBuilder(
            buildProps: (p) => [p.isPausedForCache],
            builder: (context, state) {
              // TODO: why is the server not sending paused-for-cache events?
              if (state.isPausedForCache) {
                return const CircularProgressIndicator();
              } else {
                return const SizedBox.shrink();
              }
            }),
        // TODO: implement settings page
        // IconButton(
        //   icon: const Icon(Icons.settings),
        //   onPressed: () {
        //      ...
        //   },
        // ),
        if (kDebugMode) ...[
          const SizedBox(width: 50),
        ],
      ],
    );
  }

  static String? _selectedKnownServerUri(BuildContext context) {
    final state = BlocProvider.of<ConnectionStateBloc>(context).state;
    final String? uri = switch (state) {
      Connected(:final uri) => uri,
      Connecting(:final uri) => uri,
      ConnectionError(:final uri) => uri,
      Disconnected() => null,
    };
    return knownServers.any((s) => s.uri == uri) ? uri : null;
  }

  static Future<String?> _askForServerUriMenu(BuildContext context) async {
    final textController = TextEditingController();

    return await showDialog(
      context: context,
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
    );
  }
}

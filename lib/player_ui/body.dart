import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gergle/api/commands.dart';
import 'package:gergle/api/events.dart';
import 'package:gergle/player_ui/main.dart';
import 'package:gergle/state/connection_state_bloc.dart';
import 'package:gergle/state/player_state.dart';
import 'package:gergle/state/player_state_bloc.dart';

class PlayerUIBody extends StatelessWidget {
  PlayerUIBody({super.key});

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: playerBlocBuilder(
            buildProps: (p) => [p.playlist, p.isPlaying],
            builder: (context, playerState) => ReorderableListView.builder(
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

                BlocProvider.of<PlayerStateBloc>(context)
                    .add(PlaylistChange(playerState.playlist, local: true));
              },
            ),
          ),
        ),
        SizedBox.fromSize(size: const Size.fromHeight(20)),
        _buildInputBar(context),
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

  Widget _buildInputBar(BuildContext context) {
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
        SizedBox.fromSize(size: const Size(10, 0)),
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
          onPressed: () async {
            final blocProvider = BlocProvider.of<ConnectionStateBloc>(context);
            final links = await _showAddManyLinksDialog(context);

            if (links == null) {
              return;
            }

            for (final link in links.split('\n')) {
              blocProvider.add(Command.load(link));
            }
          },
        ),
      ],
    );
  }

  Future<String?> _showAddManyLinksDialog(BuildContext context) async {
    final textController = TextEditingController();

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add many links'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Links',
            hintText: 'One link per line',
          ),
          maxLines: 10,
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
              Navigator.of(context).pop(textController.text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

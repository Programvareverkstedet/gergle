import 'package:flutter/foundation.dart';

class ServerOption {
  final String label;
  final String uri;

  const ServerOption(this.label, this.uri);
}

const List<ServerOption> baseServers = [
  ServerOption('Georg', 'wss://georg-backend.pvv.ntnu.no/ws'),
  ServerOption(
    'Brzeczyszczykiewicz',
    'wss://brzeczyszczykiewicz-backend.pvv.ntnu.no/ws',
  ),
];

const ServerOption debugServer = ServerOption(
  'Local 8009',
  'ws://localhost:8009/ws',
);

List<ServerOption> get knownServers => [
      ...baseServers,
      if (kDebugMode) debugServer,
    ];

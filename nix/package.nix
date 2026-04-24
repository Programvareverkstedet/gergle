{
  lib,
  src,

  flutter,

  isWeb ? false,
  isWasm ? false,
  isDebug ? false,
}:

(flutter.buildFlutterApplication.override { inherit flutter; }) {
  pname = let
    variant = if isWeb && isWasm then "wasm"
              else if isWeb then "web"
              else "linux";
  in "gergle-${variant}${lib.optionalString isDebug "-debug"}";
  version = "0.1.0";
  inherit src;
  autoPubspecLock = ../pubspec.lock;

  flutterMode = if isDebug then "debug" else "release";
  targetFlutterPlatform = if isWasm || isWeb then "web" else "linux";
  flutterBuildFlags = lib.optionals isWasm [ "--wasm" ];
}

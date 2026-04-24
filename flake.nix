{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: let
    inherit (nixpkgs) lib;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "armv7l-linux"
    ];

    forAllSystems = f: lib.genAttrs systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in f system pkgs);
  in {
    devShells = forAllSystems (_: pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          flutter338

          # https://github.com/NixOS/nixpkgs/issues/341147
          pkg-config
          gtk3
        ];
      };
    });

    nixosModules.default = ./module.nix;

    packages = forAllSystems (system: pkgs: let
      common = {
        version = "0.1.0";
        src = ./.;
        autoPubspecLock = ./pubspec.lock;
      };

      flutter = pkgs.flutter338;
    in {
      default = self.packages.${system}.linux;
      linux = flutter.buildFlutterApplication (common // {
        pname = "gergle-linux";
      });
      linux-debug = flutter.buildFlutterApplication (common // {
        pname = "gergle-linux-debug";
        flutterMode = "debug";
      });
      web = flutter.buildFlutterApplication (common // {
        pname = "gergle-web";
        targetFlutterPlatform = "web";
      });
      web-debug = flutter.buildFlutterApplication (common // {
        pname = "gergle-web-debug";
        flutterMode = "debug";
        targetFlutterPlatform = "web";
      });
      web-wasm = flutter.buildFlutterApplication (common // {
        pname = "gergle-wasm";
        targetFlutterPlatform = "web";
        flutterBuildFlags = [ "--wasm" ];
      });
    });

    overlays.default = final: prev: {
      gergle-desktop = self.packages.${final.stdenv.hostPlatform.system}.linux;
      gergle-web = self.packages.${final.stdenv.hostPlatform.system}.web;
      gergle-web-debug = self.packages.${final.stdenv.hostPlatform.system}.web-debug;
      gergle-web-wasm = self.packages.${final.stdenv.hostPlatform.system}.web-wasm;
    };

    apps = forAllSystems (system: pkgs: {
      default = self.apps.${system}.web;

      web = {
        type = "app";
        program = toString (pkgs.writeShellScript "gergle-web" ''
          ${pkgs.python3}/bin/python -m http.server -d ${self.packages.${system}.web}/
        '');
      };

      web-debug = {
        type = "app";
        program = toString (pkgs.writeShellScript "gergle-web-debug" ''
          ${pkgs.python3}/bin/python -m http.server -d ${self.packages.${system}.web-debug}/
        '');
      };

      web-wasm = {
        type = "app";
        program = toString (pkgs.writeShellScript "gergle-web-wasm" ''
          ${pkgs.python3}/bin/python -m http.server -d ${self.packages.${system}.web-wasm}/
        '');
      };
    });
  };
}

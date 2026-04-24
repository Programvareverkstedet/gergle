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

    nixosModules.default = ./nix/module.nix;

    packages = forAllSystems (system: pkgs: let
      src = builtins.filterSource (path: type: let
        baseName = baseNameOf (toString path);
      in !(lib.any (b: b) [
          (!(lib.cleanSourceFilter path type))
          (baseName == ".gitea" && type == "directory")
          (baseName == "nix" && type == "directory")

          (baseName == ".envrc" && type == "regular")
          (baseName == "flake.lock" && type == "regular")
          (baseName == "flake.nix" && type == "regular")
          (baseName == "module.nix" && type == "regular")
        ])) ./.;
      flutter = pkgs.flutter338;
    in {
      default = self.packages.${system}.linux;
      linux = pkgs.callPackage ./nix/package.nix {
        inherit src flutter;
      };
      linux-debug = pkgs.callPackage ./nix/package.nix {
        inherit src flutter;
        isDebug = true;
      };
      web = pkgs.callPackage ./nix/package.nix {
        inherit src flutter;
        isWeb = true;
      };
      web-debug = pkgs.callPackage ./nix/package.nix {
        inherit src flutter;
        isWeb = true;
        isDebug = true;
      };
      web-wasm = pkgs.callPackage ./nix/package.nix {
        inherit src flutter;
        isWeb = true;
        isWasm = true;
      };
    });

    overlays.default = final: prev: {
      gergle-desktop = self.packages.${final.stdenv.hostPlatform.system}.linux;
      gergle-web = self.packages.${final.stdenv.hostPlatform.system}.web;
      gergle-web-debug = self.packages.${final.stdenv.hostPlatform.system}.web-debug;
      gergle-web-wasm = self.packages.${final.stdenv.hostPlatform.system}.web-wasm;
    };

    apps = forAllSystems (system: pkgs: {
      default = self.apps.${system}.web;

      linux = {
        type = "app";
        program = lib.getExe self.packages.${system}.linux;
      };

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

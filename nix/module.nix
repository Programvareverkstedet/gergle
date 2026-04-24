{ pkgs, lib, config, ... }:
let
  cfg = config.services.gergle;
in
{
  options.services.gergle = {
    enable = lib.mkEnableOption "Enable the gergle service";

    package = lib.mkPackageOption pkgs "gergle-web-wasm" {
      example = "gergle-web-debug";
    };

    virtualHost = lib.mkOption {
      type = lib.types.str;
      example = "gergle.example.com";
      description = "Virtual host to serve gergle on";
    };

    location = lib.mkOption {
      type = lib.types.str;
      default = "/";
      description = "Location to serve gergle on";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.virtualHost}" = {
        locations.${cfg.location}.root = "${cfg.package}/";
      };
    };
  };
}
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.services.wallpaperRulette;
in
{
  options = {
    services.wallpaperRulette = {
      enable = lib.mkEnableOption "Wallpaper Rulette, a way to roll around in your wallpapers";
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs.wallpaper_rulette.packages.${pkgs.stdenv.hostPlatform.system}.default;
        description = "The wallpaper_rulette package to use.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.wallpaperRulette = {
      enable = true;
      description = "A wallpaper rulette";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/wallpaper_rulette";
        RestartSec = 5;
      };
    };
  };
}

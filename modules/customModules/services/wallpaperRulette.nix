{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.services.wallpaperRulette;
  inherit (lib)
    mkIf
    types
    mkOption
    mkEnableOption
    literalExpression
    ;
in
{
  options = {
    services.wallpaperRulette = {
      enable = mkEnableOption "Wallpaper Rulette";
      package = mkOption {
        type = types.package;
        default = inputs.wallpaper_rulette.packages.${pkgs.system}.default;
        defaultText = literalExpression "inputs.wallpaper_rulette.packages.\${pkgs.system}.default";
        description = ''
          The wallpaper_rulette package to shoot (change)
          randomly at any of your wallpapers.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.wallpaperRulette = {
      description = "A wallpaper rulette";
      wantedBy = [ "graphical-session.target" ];

      serviceConfig = {
        RemainAfterExit = false;
        Restart = "on-failure";
        RestartSec = "3";
        ExecStart = "${cfg.package}/bin/wallpaper_rulette";
      };

    };
  };
}

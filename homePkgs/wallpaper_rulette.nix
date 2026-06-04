{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.wallpaper_rulette;
in
{
  options = {
    services.wallpaper_rulette = {
      enable = lib.mkEnableOption "Wallpaper Rulette, a way to roll around in your wallpapers";
      package = lib.mkPackageOption pkgs [ "haskellPackages" "wallpaper_rulette" ] { };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.wallpaper_rulette = {
      enable = true;
      description = "A wallpaper rulette";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "/home/randy/Desktop/cppProyects/wallpaper_rulette/build/bin/wallpaper_rulette";
        RestartSec = 5;
      };
    };

    home.packages = [ cfg.package ];
  };
}

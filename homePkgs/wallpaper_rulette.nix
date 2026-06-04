{ pkgs, inputs, ... }:

{
  systemd.user.services.wallpaper-rulette = {
    Unit = {
      Description = "C++ Wallpaper Rulette Service for Niri";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${inputs.wallpaper-rulette.packages.${pkgs.system}.default}/bin/wallpaper_rulette";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

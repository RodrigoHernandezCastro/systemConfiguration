{ pkgs, ... }: {
  xdg.dataFile = {
    "v2rayN/bin/sing_box/sing-box".source = "${pkgs.sing-box}/bin/sing-box";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };

  xdg.desktopEntries = {
    "qt5ct" = {
      name = "Qt5 Configuration Tool";
      noDisplay = true;
    };

    "qt6ct" = {
      name = "Qt6 Configuration Tool";
      noDisplay = true;
    };

    "kitty" = {
      name = "kitty";
      noDisplay = true;
    };

    "blueman-adapters" = {
      name = "Bluetooth Adaptors";
      noDisplay = true;
    };
  };
}

{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.stylix.homeModules.stylix ];
  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/horizon-dark.yaml";

    targets = {
      gtk.enable = true;
      qt.enable = true;
      fuzzel.enable = true;
      mako.enable = true;
      zed.enable = true;
      obsidian.enable = true;
      firefox.enable = true;
      alacritty.enable = true;
      kitty.enable = true;
      swaylock.enable = true;
      mpv.enable = true;
      anki.enable = true;
      fzf.enable = true;
      spicetify.enable = true;
      waybar = {
        enable = true;
        addCss = false;
      };
    };
  };
}

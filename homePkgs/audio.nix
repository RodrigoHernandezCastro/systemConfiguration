{ pkgs, ... }:

{
  home.packages = with pkgs; [
    easyeffects
    pavucontrol
  ];

  services.easyeffects = {
    enable = true;
  };
}

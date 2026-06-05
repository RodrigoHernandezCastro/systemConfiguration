{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    whatsapp-electron
    modrinth-app
    glfw3-minecraft
    google-chrome
    git
    alacritty
    pciutils
    mako
    swaybg
    swaylock
    wl-clipboard
    brightnessctl
    playerctl
    nh
    inputs.vtubfetch.packages.${pkgs.stdenv.hostPlatform.system}.default
    easyeffects
    telegram-desktop
    lxqt.lxqt-policykit
    prismlauncher
    nmap
    arp-scan
    curl
    jq
    mpv
    libnotify
    sl
    unzip
    warpd
    foliate
    corefonts
    onlyoffice-desktopeditors
    mpv
    prismlauncher
    obs-studio
  ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "corefonts"
    ];
  virtualisation.docker.enable = true;
  # programs
  programs.niri.enable = true;
  programs.dconf.enable = true;
  # Install firefox.
  programs.nix-ld.enable = true;

  programs.firefox.enable = true;
  programs.steam.enable = true;

  # Remove packages here:
  programs.nano.enable = false;
  documentation = {
    enable = false;
    man.enable = false;
  };
}

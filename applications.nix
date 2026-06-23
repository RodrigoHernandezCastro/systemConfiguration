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
    fzf
    playerctl
    nh
    inputs.vtubfetch.packages.${pkgs.stdenv.hostPlatform.system}.default
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
    zotero
    mailspring
    super-productivity
    kdePackages.filelight
    kdePackages.gwenview
    easyeffects
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "corefonts"
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  virtualisation.docker.enable = true;

  # programs
  programs.niri.enable = true;
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.localsend.enable = true;
  programs.waybar.enable = true;
  programs.nano.enable = true;

  # remove packages
  documentation = {
    enable = false;
    man.enable = false;
  };
}

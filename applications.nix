{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    whatsapp-electron
    modrinth-app
    google-chrome
    brave
    discord
    git
    alacritty
    fuzzel
    mako
    swaybg
    swaylock
    xwayland-satellite
    wl-clipboard
    brightnessctl
    playerctl
    pavucontrol
    nh
    inputs.vtubfetch.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
    easyeffects
    telegram-desktop
    vscode
    lxqt.lxqt-policykit
    prismlauncher
    nmap
    arp-scan
    curl
    jq
    mpv
    libnotify
  ];

  services = {
    displayManager.ly.enable = true;
    blueman.enable = true;
  };

  programs.firefox.enable = true;
  programs.steam.enable = true;

  #Remove packages here:
  programs.nano.enable = false;
  documentation = {
    enable = false;
    man.enable = false;
  };
}
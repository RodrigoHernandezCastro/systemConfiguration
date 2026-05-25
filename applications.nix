{
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    whatsapp-electron
    modrinth-app
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
    palemoon-bin
    unzip
  ];

  services = {
    displayManager.ly.enable = true;
    blueman.enable = true;
    tailscale.enable = true;
    openssh.enable = true;
  };

  programs.firefox.enable = true;
  programs.steam.enable = true;

  # Remove packages here:
  programs.nano.enable = false;
  documentation = {
    enable = false;
    man.enable = false;
  };
}

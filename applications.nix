{
  pkgs,
  inputs,
  ...
}:
let
  java-mcef = pkgs.writeShellScriptBin "java-mcef" ''
    exec ${pkgs.steam-run}/bin/steam-run ${pkgs.jdk21}/bin/java "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    whatsapp-electron
    modrinth-app
    java-mcef
    google-chrome
    brave
    discord
    git
    alacritty
    mako
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
  ];

  services = {
    displayManager.ly.enable = true;
    blueman.enable = true;
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

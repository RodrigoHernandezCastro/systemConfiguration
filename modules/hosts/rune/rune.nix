{ self, ... }:
let
  inherit (self.lib) mkSystem;
in
{
  config.flake.nixosConfigurations.rune = mkSystem {
    configuration = {
      system = "x86_64-linux";
    };

    nixosModules = with self.nixosModules; [
      configuration
      boot
      hardware-configuration
      networking
      users

      fonts
      virtualisation
      niri

      programs-core
      programs-localsend
      programs-steam
      programs-virt-manager

      blueman
      flatpak
      ly
      sddm-astronaut
      openssh
      pipewire
      playerctld
      printing
      tailscale
      wallpaperRulette

      systemPackages-games
      systemPackages-kde
      systemPackages-productivity
      systemPackages-social
      systemPackages-system
      systemPackages-virt
      systemPackages-web

      translator
      home-manager
    ];

    homeModules = with self.homeModules; [
      easyeffects
    ];
  };
}

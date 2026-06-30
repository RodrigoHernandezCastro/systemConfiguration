{ self, ... }:
let
  inherit (self.lib) mkSystem;
in
{
  flake.nixosConfigurations.runeVariant = mkSystem {
    configuration = {
      system = "x86_64-linux";
    };

    nixosModules = with self.nixosModules; [
      runeVariant-configuration
      runeVariant-boot
      runeVariant-hardware-configuration
      runeVariant-networking
      runeVariant-users

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

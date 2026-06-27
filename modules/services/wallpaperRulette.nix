{
  flake.nixosModules.wallpaperRulette = {
    imports = [
      ../customModules/services/wallpaperRulette.nix
    ];
    services.wallpaperRulette.enable = true;
  };
}

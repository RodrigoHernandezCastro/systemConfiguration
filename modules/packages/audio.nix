{
  flake.nixosModules.systemPackages-audio =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        easyeffects
      ];
    };
}

{
  flake.nixosModules.systemPackages-web =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        google-chrome
      ];
    };
}

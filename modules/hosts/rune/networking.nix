{
  flake.nixosModules.networking =
    {
      ...
    }:
    {
      # Enable networking
      networking = {
        hostName = "rune";
        networkmanager.enable = true;
      };
    };
}

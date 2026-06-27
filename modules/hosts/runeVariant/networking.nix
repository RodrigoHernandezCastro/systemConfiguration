{
  flake.nixosModules.runeVariant-networking =
    {
      ...
    }:
    {
      # Enable networking
      networking = {
        hostName = "runeVariant";
        networkmanager.enable = true;
      };
    };
}

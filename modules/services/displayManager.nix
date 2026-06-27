{
  flake.nixosModules.ly =
    {
      ...
    }:
    {
      services.displayManager.ly.enable = false;
    };
}

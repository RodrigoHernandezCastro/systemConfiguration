{
  flake.nixosModules.playerctld =
    {
      ...
    }:
    {
      services.playerctld.enable = true;
    };
}

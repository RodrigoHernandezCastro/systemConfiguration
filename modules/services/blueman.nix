{
  flake.nixosModules.blueman =
    {
      ...
    }:
    {
      services.blueman.enable = true;
    };
}

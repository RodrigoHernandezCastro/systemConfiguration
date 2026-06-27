{
  flake.homeModules.default = { };

  flake.nixosModules.programs-steam =
    {
      ...
    }:
    {
      programs.steam = {
        enable = true;
      };
    };
}

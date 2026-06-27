{
  flake.nixosModules.programs-localsend =
    {
      ...
    }:
    {
      programs.localsend.enable = true;
    };
}

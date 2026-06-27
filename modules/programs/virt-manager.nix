{
  flake.nixosModules.programs-virt-manager =
    {
      ...
    }:
    {
      programs.virt-manager.enable = true;
    };
}

{
  flake.nixosModules.systemPackages-virt =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        virt-viewer
        spice
        spice-gtk
        spice-protocol
      ];
    };
}

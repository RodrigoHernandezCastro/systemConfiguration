{
  flake.nixosModules.runeVariant-boot =
    {
      pkgs,
      ...
    }:
    {
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_6_6;
        supportedFilesystems = [ "ntfs" ];
      };
    };
}

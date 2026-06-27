{
  flake.nixosModules.boot =
    {
      pkgs,
      ...
    }:
    {
      boot = {
        loader = {
          limine.enable = true;
          limine.style.wallpapers = [ ];
          efi.canTouchEfiVariables = true;
        };
        initrd = {
          availableKernelModules = [
            "xhci_pci"
            "ahci"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
          kernelModules = [ "kvm_amd" ];
        };
        extraModulePackages = [ ];
        kernelPackages = pkgs.linuxPackages_latest;
        supportedFilesystems = [ "ntfs" ];
      };
    };
}

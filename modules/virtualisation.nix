{
  flake.nixosModules.virtualisation =
    {
      pkgs,
      ...
    }:
    {
      virtualisation.docker.enable = true;

      # Enable libvirt with QEMU/KVM
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    };
}

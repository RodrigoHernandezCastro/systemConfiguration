{
  flake.nixosModules.systemPackages-system =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        pciutils
        brightnessctl
        nmap
        arp-scan
        unzip
        wl-clipboard
        libnotify
        lxqt.lxqt-policykit
        corefonts
        sl
        mako
        swaybg
        warpd
        inputs.vtubfetch.packages.${pkgs.stdenv.hostPlatform.system}.default

      ];
    };
}

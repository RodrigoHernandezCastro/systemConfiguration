{
  flake.nixosModules.systemPackages-social =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        whatsapp-electron
        telegram-desktop
      ];
    };
}

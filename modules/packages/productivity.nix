{
  flake.nixosModules.systemPackages-productivity =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        onlyoffice-desktopeditors
        zotero
        foliate
        super-productivity
      ];
    };
}

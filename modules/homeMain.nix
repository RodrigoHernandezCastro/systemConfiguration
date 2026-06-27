{
  inputs,
  ...
}:
{
  flake.nixosModules.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };

      users.randy = {
        home.username = "randy";
        home.homeDirectory = "/home/randy";
        home.stateVersion = "25.11";

        gtk.enable = true;

        imports = [
          (inputs.import-tree ./homePkgs)
          (inputs.import-tree ./niri/utils)
          inputs.willowispll.homeModules.nixcord
          inputs.willowispll.homeModules.mako
        ];
      };
    };
  };
}

{
  description = "Basic Main Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    import-tree.url = "github:vic/import-tree";

    wallpaper_rulette = {
      url = "github:RodrigoHernandezCastro/wallpaper_rulette";
    };

    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vtubfetch = {
      url = "github:Willowispll/vtubfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    willowispll = {
      url = "github:Willowispll/dendriticWillowispll";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self, ... }@inputs:
    {
      nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./homeMain.nix
          ./fonts.nix
          ./niri/niri.nix
          ./virtualisation.nix
        ]
        ++ inputs.nixpkgs.lib.filesystem.listFilesRecursive ./services
        ++ inputs.nixpkgs.lib.filesystem.listFilesRecursive ./hosts/rune
        ++ inputs.nixpkgs.lib.filesystem.listFilesRecursive ./packages
        ++ inputs.nixpkgs.lib.filesystem.listFilesRecursive ./programs;
      };
      nixosModules = import ./customModules;
    };
}

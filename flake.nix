{
  description = "Basic Main Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

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

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    willowispll = {
      url = "github:Willowispll/dendriticWillowispll";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    translator = {
      url = "path:/home/randy/Desktop/cppProyects/translator";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree.matchNot ".*/(homePkgs|niri/utils|customModules)/.*" ./modules);
}

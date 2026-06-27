{
  flake.nixosModules.systemPackages-games =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        glfw3-minecraft
        modrinth-app
      ];
    };
}

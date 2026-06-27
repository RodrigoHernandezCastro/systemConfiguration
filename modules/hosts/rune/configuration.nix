{
  flake.nixosModules.configuration =
    {
      lib,
      ...
    }:
    {
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        extraOptions = "warn-dirty = false ";
      };

      security.polkit.enable = true;

      # Set your time zone.
      time.timeZone = "America/Santiago";
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "es_CL.UTF-8";
        LC_IDENTIFICATION = "es_CL.UTF-8";
        LC_MEASUREMENT = "es_CL.UTF-8";
        LC_MONETARY = "es_CL.UTF-8";
        LC_NAME = "es_CL.UTF-8";
        LC_NUMERIC = "es_CL.UTF-8";
        LC_PAPER = "es_CL.UTF-8";
        LC_TELEPHONE = "es_CL.UTF-8";
        LC_TIME = "es_CL.UTF-8";
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_STATE_HOME = "/home/randy/.local/state";
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "corefonts" ];
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      # remove packages
      documentation = {
        enable = false;
        man.enable = false;
      };

      system.stateVersion = "25.11";
    };
}

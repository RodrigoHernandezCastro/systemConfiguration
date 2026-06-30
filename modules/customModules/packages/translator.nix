{
  lib,
  inputs,
  ...
}:
{
  options.xdg.desktopEntries = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
    internal = true;
    description = "Dummy option to satisfy the translator module's xdg.desktopEntries usage in NixOS context.";
  };

  imports = [ inputs.translator.nixosModules.default ];

  config.programs.subtitle_translator = {
    enable = true;
    geminiKeyFile = "/run/secrets/gemini-key";
    libretranslateUrl = "http://localhost:5000";
    sourceLang = "ru";
    targetLang = "es";
    autoStart = true;
  };
}

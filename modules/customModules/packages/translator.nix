{
  inputs.translator.url = "path:/home/randy/Desktop/cppProyects/translator";

  outputs =
    {
      self,
      nixpkgs,
      translator,
      ...
    }:
    {
      imports = [ translator.nixosModules.default ];
      programs.subtitle_translator = {
        enable = true;
        geminiKeyFile = "/run/secrets/gemini-key";
        libretranslateUrl = "http://localhost:5000";
        sourceLang = "ru";
        targetLang = "es";
        autoStart = true; # set true to auto-launch with graphical session
      };
    };
}

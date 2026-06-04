{
  pkgs,
  config,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_6_6;
    supportedFilesystems = [ "ntfs" ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    extraOptions = "warn-dirty = false ";
  };
  security.polkit.enable = true;

  # Portal configuration for screensharing on niri
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # Set your time zone.
  time.timeZone = "America/Santiago";

  # Select internationalisation properties.
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

  # Virtualization
  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable libvirt with QEMU/KVM
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  systemd.services.kokoro-tts = {
    description = "Kokoro TTS FastAPI Server";
    after = [
      "network.target"
      "docker.service"
    ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      ${pkgs.docker}/bin/docker rm -f kokoro-fastapi 2>/dev/null || true
      ${pkgs.docker}/bin/docker run --rm \
        -p 8880:8880 \
        --name kokoro-fastapi \
        ghcr.io/remsky/kokoro-fastapi-cpu:latest
    '';

    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ vulkan-loader ];
  };

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:10:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
  programs.niri.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "la-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.flatpak.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.randy = {
    isNormalUser = true;
    description = "Randy";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "docker"
      "libvirtd"
      "kvm"
    ];
    packages = with pkgs; [
      kdePackages.kate

    ];
  };

  fileSystems."/mnt/disk_1tb" = {
    device = "/dev/disk/by-uuid/9250552450550FF9";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "defaults"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
    ];
  };

  fileSystems."/mnt/disk_500gb_1" = {
    device = "/dev/disk/by-uuid/82E0EA2AE0EA23DF";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "defaults"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
    ];
  };

  fileSystems."/mnt/disk_500gb_HDD_1" = {
    device = "/dev/disk/by-uuid/7C28ECB02419F06D";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "defaults"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
    ];
  };

  # programs
  programs.dconf.enable = true;
  # Install firefox.
  programs.firefox.enable = true;

  programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}

# profiles/personal/configuration.nix

{ inputs, config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./secrets.nix
  ];

  # Ensure NVIDIA kernel modules are loaded and Nouveau is blacklisted.
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  # Enable Kernel Mode Setting for smoother boot and TTY.
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixbook";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # PAM integration
  security.pam.services = {
    login.enableGnomeKeyring = true;
    swaylock.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
  };

  # Enable gnome keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Lid suspend
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "suspend";
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = "*";
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };

  programs.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Graphics hardware configuration
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Enable and configure NVIDIA proprietary drivers using NixOS hardware module.
  hardware.nvidia = {
    modesetting.enable = true;
    # Power management features like Runtime D3 (RTD3).
    powerManagement.enable = true;
    powerManagement.finegrained = true; # Allow more power saving states.
    open = false; # Use proprietary kernel module, not the open-source one.
    nvidiaSettings = true; # Install nvidia-settings tool.
    # Use the stable NVIDIA driver package provided by the current kernel.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Configure NVIDIA PRIME for GPU offloading on Optimus laptops.
  hardware.nvidia.prime = {
    # Enable render offload mode.
    offload = {
      enable = true;
      enableOffloadCmd = true; # Provides the `nvidia-offload` command wrapper.
    };
    # Explicitly set PCI bus IDs for Intel and NVIDIA GPUs.
    # Find these using `lspci | grep -E 'VGA|3D'`.
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };

  # === Sound Configuration ===
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.brianl = {
    isNormalUser = true;
    description = "Brian Lucas";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Allow installation of unfree packages system-wide.
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    nautilus
    gnome-keyring
    libsecret

    inputs.agenix.packages.${pkgs.system}.default

    #GPU tools
    glxinfo
    vulkan-tools
    pciutils
    nvtopPackages.full
    intel-gpu-tools

    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
  ];

  # Enable Zsh globally. While user shell preference is set in home-manager,
  # enabling it here ensures the package is available system-wide if needed
  # and sets it as the default shell for the user defined below.
  programs.zsh.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

  # List services that you want to enable:
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  # Automatic security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "04:00";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}

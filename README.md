# NixOS Configuration

This is a personal NixOS configuration for a laptop setup running Hyprland.

## Suggestions for Improvement

### 1. Neovim Configuration

Your Neovim configuration is already quite good. Consider adding:

#### Git Integration
```nix
# Add to user/app/neovim/neovim.nix in the plugins list
{
  plugin = gitsigns-nvim;
  config = toLuaFile ./nvim/plugin/gitsigns.lua;
}
```

Create `./nvim/plugin/gitsigns.lua`:
```lua
require('gitsigns').setup {
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    
    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map('n', '<leader>hs', gs.stage_hunk)
    map('n', '<leader>hr', gs.reset_hunk)
    map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)
  end
}
```

#### Project Management
```nix
# Add to user/app/neovim/neovim.nix in the plugins list
{
  plugin = telescope-project-nvim;
  config = toLuaFile ./nvim/plugin/telescope-project.lua;
}
```

Create `./nvim/plugin/telescope-project.lua`:
```lua
require('telescope').load_extension('project')

-- Add a keymap to access projects
vim.keymap.set('n', '<leader>fp', function()
  require'telescope'.extensions.project.project{}
end, { noremap = true, silent = true })
```

#### Treesitter Enhancements
```nix
# Add to user/app/neovim/neovim.nix in the plugins list
{
  plugin = nvim-treesitter-textobjects;
  config = toLuaFile ./nvim/plugin/treesitter-textobjects.lua;
}
```

Create `./nvim/plugin/treesitter-textobjects.lua`:
```lua
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}
```

#### Dashboard or Greeter
```nix
# Add to user/app/neovim/neovim.nix in the plugins list
{
  plugin = dashboard-nvim;
  config = toLuaFile ./nvim/plugin/dashboard.lua;
}
```

Create `./nvim/plugin/dashboard.lua`:
```lua
require('dashboard').setup {
  theme = 'doom',
  config = {
    header = {
      '',
      '   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆         ',
      '    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
      '          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ',
      '           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
      '          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
      '   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
      '  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
      ' ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
      ' ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ',
      '    ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆       ',
      '     ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
      '',
    },
    center = {
      {
        icon = ' ',
        icon_hl = 'Title',
        desc = 'Find File           ',
        desc_hl = 'String',
        key = 'f',
        keymap = 'SPC f f',
        key_hl = 'Number',
        action = 'Telescope find_files'
      },
      {
        icon = ' ',
        icon_hl = 'Title',
        desc = 'Find Text           ',
        desc_hl = 'String',
        key = 'g',
        keymap = 'SPC f g',
        key_hl = 'Number',
        action = 'Telescope live_grep'
      },
      {
        icon = ' ',
        icon_hl = 'Title',
        desc = 'Recent Files        ',
        desc_hl = 'String',
        key = 'r',
        keymap = 'SPC f r',
        key_hl = 'Number',
        action = 'Telescope oldfiles'
      },
      {
        icon = ' ',
        icon_hl = 'Title',
        desc = 'Config Files        ',
        desc_hl = 'String',
        key = 'c',
        keymap = 'SPC f c',
        key_hl = 'Number',
        action = 'lua require("telescope.builtin").find_files({cwd = "~/.dotfiles/"})'
      },
    },
    footer = {}
  }
}
```

### 2. Nix Garbage Collection

Set up automatic garbage collection to keep your system lean:

```nix
# Add to profiles/personal/configuration.nix
nix = {
  settings = {
    # Keep your existing settings here
    experimental-features = [ "nix-command" "flakes" ];

#### Auto-mount External Drives

```nix
# Add to profiles/personal/configuration.nix
services.udisks2.enable = true;
services.gvfs.enable = true; # For mounting as normal user
services.devmon.enable = true;

# Install a GUI for disk management
environment.systemPackages = with pkgs; [
  # Your existing packages
  gnome.gnome-disk-utility
  udiskie
];

# Add to the user's Hyprland exec-once
# "udiskie --tray" in the exec-once section
```

#### Battery Notifications

```nix
# Add to user/wm/hyprland/hyprland.nix
home.file."${config.xdg.configHome}/hypr/scripts/battery-monitor.sh" = {
  executable = true;
  text = ''
    #!/usr/bin/env bash
    
    # Low battery threshold (%)
    LOW_THRESHOLD=15
    CRITICAL_THRESHOLD=5
    
    # Check interval (seconds)
    INTERVAL=60
    
    while true; do
      BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
      CHARGING=$(acpi -b | grep -c "Charging")
      
      if [ "$CHARGING" -eq 0 ]; then
        if [ "$BATTERY_LEVEL" -le "$CRITICAL_THRESHOLD" ]; then
          notify-send -u critical "Battery Critical!" "Battery level is $BATTERY_LEVEL%. Connect charger immediately." -i "battery-empty"
        elif [ "$BATTERY_LEVEL" -le "$LOW_THRESHOLD" ]; then
          notify-send -u normal "Battery Low" "Battery level is $BATTERY_LEVEL%. Connect charger soon." -i "battery-low"
        fi
      fi
      
      sleep $INTERVAL
    done
  '';
};

# Add to exec-once
"exec-once" = [
  # Your existing exec commands
  "~/.config/hypr/scripts/battery-monitor.sh &"
];

# Ensure acpi is installed
home.packages = with pkgs; [
  # Your existing packages
  acpi
];
```

#### Weather in Waybar

```nix
# Update your waybar config.jsonc to include a weather module
# Add to user/wm/hyprland/waybar/config.jsonc in the modules-right array
"custom/weather",

# Then add the module configuration at the end of the file
"custom/weather": {
  "exec": "curl 'https://wttr.in/?format=1' | tr -d '+'",
  "interval": 3600,
  "format": "{}",
  "tooltip": false
}
```

### 11. Development Environments with Devenv.sh

[devenv.sh](https://devenv.sh/) is a powerful developer environment manager built on Nix.

```nix
# Add to profiles/personal/home.nix
home.packages = with pkgs; [
  devenv
];

# Create a custom shell hook for project initialization
programs.zsh.initExtra = ''
  # ... your existing initExtra content

  # Function to create a new dev environment
  function newdev() {
    if [ -z "$1" ]; then
      echo "Please provide a project name"
      return 1
    fi
    
    mkdir -p "$1"
    cd "$1" || return
    
    # Initialize devenv
    devenv init
    
    # Open the devenv.nix file for editing
    $EDITOR devenv.nix
  }
  
  # Function to activate an existing dev environment
  function devup() {
    if [ -f "devenv.nix" ]; then
      devenv shell
    else
      echo "No devenv.nix found in the current directory"
    fi
  }
'';
```

Example devenv.nix file for a Python project:

```nix
{ pkgs, ... }:

{
  # Packages for the environment
  packages = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.black
    python311Packages.flake8
    python311Packages.pytest
  ];

  # Python environment
  languages.python = {
    enable = true;
    version = "3.11";
    
    # Virtual environment
    venv = {
      enable = true;
      requirements = "./requirements.txt";
    };
  };

  # Scripts you can run with devenv up
  scripts.start.exec = "python app.py";
  scripts.test.exec = "pytest";
  scripts.lint.exec = "flake8 && black --check .";
  scripts.format.exec = "black .";

  # Enable pre-commit hooks
  pre-commit.hooks = {
    black.enable = true;
    flake8.enable = true;
    trailing-whitespace.enable = true;
  };

  # Environment variables
  env = {
    PYTHONPATH = "./";
    APP_ENV = "development";
  };
}
```

### 12. Container Management with Podman

Podman is a daemonless container engine similar to Docker but with better integration into systemd.

```nix
# Add to profiles/personal/configuration.nix
virtualisation = {
  podman = {
    enable = true;
    dockerCompat = true; # Symlink /var/run/docker.sock to podman
    defaultNetwork.settings.dns_enabled = true;
  };
};

# Install UI tools
environment.systemPackages = with pkgs; [
  podman-compose
  podman-tui  # Terminal UI for Podman
];

# Add podman aliases to your shell
programs.zsh.shellAliases = {
  # Your existing aliases
  
  # Podman aliases with Docker-compatible names
  docker = "podman";
  docker-compose = "podman-compose";
  
  # Common container operations
  dps = "podman ps";
  dstop = "podman stop";
  drm = "podman rm";
  dimages = "podman images";
  dprune = "podman system prune --all";
};
```

### 13. Advanced Hyprland Window Rules

Configure window rules for specific applications:

```nix
# Add to user/wm/hyprland/hyprland.nix in the windowrulev2 section
windowrulev2 = [
  # Your existing rules
  
  # Firefox PiP window - float and sticky
  "float,title:^(Picture-in-Picture)$"
  "pin,title:^(Picture-in-Picture)$"
  
  # Image viewers
  "float,class:^(imv)$"
  "center,class:^(imv)$"
  
  # File dialogs
  "float,title:^(Open File)$"
  "float,title:^(Save As)$"
  
  # Games - Fullscreen and better performance
  "immediate,class:^(steam_app_).*$"
  
  # Specific window size for specific apps
  "size 1200 800,class:^(org.gnome.Nautilus)$"
  "center,class:^(org.gnome.Nautilus)$"
  
  # App to specific workspace
  "workspace 2 silent,class:^(firefox)$"
  "workspace 3 silent,class:^(code-oss)$"
  "workspace 4 silent,class:^(org.kde.krita)$"
];
```

### 14. System Backup Solution

Set up automatic backups with restic:

```nix
# Add to profiles/personal/configuration.nix
services.restic.backups = {
  homeBackup = {
    initialize = true;
    paths = [
      "/home/brianl/Documents"
      "/home/brianl/Pictures"
      "/home/brianl/Projects"
      # Add more directories to back up
    ];
    exclude = [
      "**/.cache"
      "**/node_modules"
      "**/__pycache__"
      "**/target"
    ];
    repository = "/mnt/backup/restic";  # or use a remote repository like "sftp:user@host:/backups"
    passwordFile = "/etc/nixos/restic-password";  # Store your password securely
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
};

# Create a password file with restricted permissions
system.activationScripts.restic-password = ''
  if [ ! -f /etc/nixos/restic-password ]; then
    echo "your-secure-password" > /etc/nixos/restic-password
    chmod 600 /etc/nixos/restic-password
  fi
'';
```

### 15. GPU Acceleration and Hardware Optimizations

```nix
# Add to profiles/personal/configuration.nix - adjust for your specific hardware
hardware = {
  # Enable OpenGL
  opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;  # For 32-bit applications
    
    # For Intel GPUs
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  
  # For better power management
  cpu.intel.updateMicrocode = true;
  
  # For better SSD performance
  enableRedistributableFirmware = true;
};

# Add appropriate file system mount options for SSD
fileSystems."/" = {
  # Your existing config
  options = [ "noatime" "nodiratime" "discard=async" ];
};

# Optimize I/O scheduler for SSD
boot.kernelParams = [
  # Your existing kernel params
  "elevator=none"  # Disable I/O scheduler for SSDs
];

# For better audio quality
sound.enable = true;
hardware.pulseaudio.enable = false;  # We're using PipeWire
security.rtkit.enable = true;  # For PipeWire to acquire realtime priority
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  jack.enable = true;  # For professional audio tools
  
  # Better audio settings
  config.pipewire = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 8192;
    };
  };
};
```
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    
    # Auto optimize store to save space
    auto-optimise-store = true;
  };
  
  # Garbage collection
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # Prevent garbage collection of current system
  extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
```

### 3. Code Organization

Create a proper module system:

```nix
# Create a file: modules/default.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware
    ./services
    ./desktop
    ./system
  ];
}
```

Example module:

```nix
# modules/system/boot.nix
{ config, lib, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Kernel parameters for better laptop support
    kernelParams = [
      "quiet"
      "splash"
      "usbcore.autosuspend=0"
    ];
    
    # Improved power management
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };
}
```

### 4. Reproducibility Enhancements

Improve your flake.nix:

```nix
{
  description = "My NixOS Configuration";

  inputs = {
    # Use a specific commit/tag for even better reproducibility
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      # Make hyprland use your nixpkgs instead of its own
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Add more inputs here as needed
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # For secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      
      # Create a function to generate system configurations
      mkSystem = { system, hostname, username, extraModules ? [] }:
        lib.nixosSystem {
          inherit system;
          modules = [
            # Base configuration
            ./hosts/${hostname}/configuration.nix
            
            # Import home-manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./homes/${username}/home.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                inherit username;
                inherit hostname;
              };
            }
          ] ++ extraModules;
          
          specialArgs = {
            inherit inputs;
            inherit username;
            inherit hostname;
          };
        };
    in {
      nixosConfigurations = {
        # Your laptop configuration
        nixbook = mkSystem {
          system = "x86_64-linux";
          hostname = "nixbook";
          username = "brianl";
          extraModules = [
            hyprland.nixosModules.default
            # Add other modules as needed
          ];
        };
        
        # You can add more configurations here
      };
      
      # Add additional outputs
      homeConfigurations = {
        # For use with standalone home-manager
        "brianl@nixbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs;
            username = "brianl";
            hostname = "nixbook";
          };
          modules = [
            ./homes/brianl/home.nix
          ];
        };
      };
    };
}
```

### 5. Performance Improvements

#### ZRam Configuration

```nix
# Add to profiles/personal/configuration.nix
zramSwap = {
  enable = true;
  algorithm = "zstd";
  memoryPercent = 50; # Use up to 50% of RAM for compressed swap
};
```

#### Power Management

```nix
# Add to profiles/personal/configuration.nix
powerManagement = {
  enable = true;
  powertop.enable = true;
  cpuFreqGovernor = "ondemand";
};

services.thermald.enable = true;
services.tlp = {
  enable = true;
  settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    
    # PCI Runtime Power Management
    RUNTIME_PM_ON_AC = "on";
    RUNTIME_PM_ON_BAT = "auto";
    
    # CPU Energy/Performance Policies
    ENERGY_PERF_POLICY_ON_AC = "performance";
    ENERGY_PERF_POLICY_ON_BAT = "power";
    
    # Battery charge thresholds (ThinkPads only)
    # START_CHARGE_THRESH_BAT0 = 40; # 40%
    # STOP_CHARGE_THRESH_BAT0 = 80;  # 80%
  };
};
```

#### Nix-ld for Better Compatibility

```nix
# Add to profiles/personal/configuration.nix
programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    # Common runtime dependencies
    stdenv.cc.cc
    zlib
    glib
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    libGL
    # Add any other libraries your applications might need
  ];
};
```

### 6. Security

#### Automatic Security Updates

```nix
# Add to profiles/personal/configuration.nix
system.autoUpgrade = {
  enable = true;
  dates = "04:00";
  allowReboot = false; # Set to true if you want automatic reboots
  flake = "/home/brianl/.dotfiles";
  flags = [
    "--update-input"
    "nixpkgs"
    "-L" # print logs
  ];
};
```

#### AppArmor

```nix
# Add to profiles/personal/configuration.nix
security = {
  apparmor = {
    enable = true;
    packages = with pkgs; [ apparmor-profiles apparmor-utils ];
  };
  
  # Hardening options
  protectKernelImage = true;
  forcePageTableIsolation = true;
  lockKernelModules = false; # Set to true for maximum security, but may break hardware functionality
};
```

#### Firewall Configuration

```nix
# Add to profiles/personal/configuration.nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 
    # Add any ports you need open here
  ];
  allowedUDPPorts = [ 
    # Add any UDP ports here
  ];
  # Ping is useful for network diagnostics
  allowPing = true;
};
```

### 7. Hyprland Improvements

#### Add Notification Daemon (Mako)

```nix
# Add to user/wm/hyprland/hyprland.nix in home.packages
home.packages = with pkgs; [
  # Your existing packages
  mako
  libnotify
];

# Add configuration
home.file."${config.xdg.configHome}/mako/config".text = ''
  # Mako configuration
  max-history=100
  sort=-time

  # Appearance
  font=FiraCode Nerd Font 11
  width=300
  height=100
  margin=10
  padding=15
  border-size=2
  border-radius=10
  icon-path=/usr/share/icons/Papirus-Dark
  max-icon-size=48
  
  # Colors (Catppuccin Mocha)
  background-color=#1e1e2e
  text-color=#cdd6f4
  border-color=#89b4fa
  progress-color=over #89b4fa

  # Behavior
  default-timeout=5000
  ignore-timeout=0
  
  # Keybindings
  on-button-left=dismiss
  on-button-middle=none
  on-button-right=dismiss-all
  on-touch=dismiss

  # Styling per urgency
  [urgency=low]
  border-color=#a6e3a1
  
  [urgency=normal]
  border-color=#89b4fa
  
  [urgency=high]
  border-color=#f38ba8
  default-timeout=0
'';

# Add to hyprland settings > "exec-once"
"exec-once" = [
  "waybar & hyprpaper" 
  "mako" # Add mako to startup
];
```

#### Screen Sharing Support

```nix
# Add to profiles/personal/configuration.nix
xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
  ];
  config.common.default = "*";
  wlr = {
    enable = true;
    settings = {
      screencast = {
        output_name = "eDP-1";
        max_fps = 30;
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
  };
};

# Also add to pkgs in home.packages
pkgs.xwaylandvideobridge  # For screen sharing in apps like Discord
```

#### Enhance Hyprland Window Movements

```nix
# Add to user/wm/hyprland/hyprland.nix in the bind section
# Better window movement with SUPER+Shift+arrow keys
"$mainMod SHIFT, left, movewindow, l"
"$mainMod SHIFT, right, movewindow, r"
"$mainMod SHIFT, up, movewindow, u"
"$mainMod SHIFT, down, movewindow, d"

# Resize with SUPER+ALT+arrow keys
"$mainMod ALT, left, resizeactive, -20 0"
"$mainMod ALT, right, resizeactive, 20 0"
"$mainMod ALT, up, resizeactive, 0 -20"
"$mainMod ALT, down, resizeactive, 0 20"

# Center window
"$mainMod, C, centerwindow"

# Full screen
"$mainMod, F, fullscreen, 0"

# Toggle floating
"$mainMod SHIFT, space, togglefloating,"
```

### 8. Home Manager Improvements

#### Starship Prompt

```nix
# Add to profiles/personal/home.nix
programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    command_timeout = 1000;
    
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold red)";
    };
    
    git_branch = {
      format = "[$symbol$branch]($style) ";
      symbol = " ";
    };
    
    nix_shell = {
      format = "[$symbol$state]($style) ";
      symbol = "❄️ ";
    };
    
    directory = {
      truncation_length = 3;
      format = "[$path]($style)[$read_only]($read_only_style) ";
    };
    
    cmd_duration = {
      format = "[$duration]($style) ";
      min_time = 2000;
    };
  };
};
```

#### Direnv Integration

```nix
# Add to profiles/personal/home.nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
  enableZshIntegration = true;
};
```

#### Improved Shell Aliases

```nix
# Add to profiles/personal/home.nix -> programs.zsh
programs.zsh = {
  # your existing config
  shellAliases = {
    ll = "ls -al";
    nss = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
    hms = "home-manager switch --flake ~/.dotfiles/";
    
    # Add these new aliases
    update = "nix flake update ~/.dotfiles/";
    gc = "nix-collect-garbage -d";
    nclean = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
    
    # Git aliases
    g = "git";
    gs = "git status";
    gd = "git diff";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gco = "git checkout";
    gb = "git branch";
    
    # System aliases
    cat = "bat"; # If you install the 'bat' package
    top = "btop"; # If you install 'btop'
    df = "duf";  # If you install 'duf'
    
    # Quick edit for common files
    vimconfig = "nvim ~/.dotfiles/user/app/neovim/";
    nixconfig = "nvim ~/.dotfiles/";
  };
  
  initExtra = ''
    # Add custom functions
    function mkcd() {
      mkdir -p "$1" && cd "$1"
    }
    
    # Nix shell function to quickly enter a dev environment
    function ns() {
      nix-shell -p "$@" --run zsh
    }
    
    # Quickly search available packages
    function nixsearch() {
      nix search nixpkgs "$@"
    }
  '';
};
```

#### FZF Integration

```nix
# Add to profiles/personal/home.nix
programs.fzf = {
  enable = true;
  enableZshIntegration = true;
  defaultCommand = "fd --type f --hidden --exclude .git";
  fileWidgetCommand = "fd --type f --hidden --exclude .git";
  changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
};

home.packages = with pkgs; [
  # your existing packages
  fd  # Required for the fzf commands above
  bat  # Nice cat replacement with syntax highlighting
  ripgrep  # Better grep
];
```

### 9. Development Environment

#### Git Configuration with Useful Aliases

```nix
# Enhance your user/app/git/git.nix
{ pkgs, userSettings, ... }:

{
  home.packages = with pkgs; [ git git-lfs ];
  
  programs.git = {
    enable = true;
    userName = userSettings.name;
    userEmail = userSettings.email;
    
    # Improved delta diff viewer
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      diff.colorMoved = "default";
      
      # Enhanced logging
      format.pretty = "%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)";
      
      # Helpful settings
      help.autocorrect = 10; # Autocorrect commands after 1 second
      push.autoSetupRemote = true; # Automatically set upstream
      fetch.prune = true; # Prune deleted remote branches
    };
    
    aliases = {
      # Shortcuts
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      
      # Useful commands
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      staged = "diff --staged";
      
      # Better logs
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      
      # Find commits by commit message
      find = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short --grep=$1; }; f";
      
      # Show the history of a file with diffs
      filelog = "log -p --follow";
      
      # Create a new branch and switch to it
      new = "!f() { git checkout -b $1; }; f";
      
      # Check what you're about to push
      prepush = "log @{u}..";
      
      # Remove branches that have been merged into master
      cleanup = "!git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d";
    };
    
    # Use the correct SSH key for GitHub
    includes = [
      {
        condition = "gitdir:~/github/";
        contents = {
          user.email = "bcl1713@github.com"; # Use a different email for GitHub repos if needed
        };
      }
    ];
  };
}
```

#### Development Tools

```nix
# Add to profiles/personal/home.nix
home.packages = with pkgs; [
  # Development tools
  devbox
  gh  # GitHub CLI
  jq  # JSON processor
  yq  # YAML processor
  
  # Language-specific tools
  nodePackages.npm
  nodejs
  yarn
  rustup
  go
  python311
  python311Packages.pip
  python311Packages.black # Python formatter
  
  # Build tools
  cmake
  gnumake
  gcc
  
  # Utilities
  docker-compose
  htop
  btop
  duf
  httpie
  bat
];
```

### 10. Quality of Life

#### Clipboard Manager

```nix
# Add to user/wm/hyprland/hyprland.nix
home.packages = with pkgs; [
  # Your existing packages
  clipman
  wl-clipboard
];

# Add to exec-once
"exec-once" = [
  "waybar & hyprpaper"
  "mako"
  "wl-paste -t text --watch clipman store" # Add clipboard manager
];

# Add a keybinding
bind = [
  # Your existing bindings
  "$mainMod, V, exec, clipman pick -t wofi"
];
```

#### Better Screenshot Utility

```nix
# Add to user/wm/hyprland/hyprland.nix
home.packages = with pkgs; [
  # Your existing packages
  grim
  slurp
  swappy  # For editing screenshots
];

home.file."${config.xdg.configHome}/hypr/scripts/screenshot.sh" = {
  executable = true;
  text = ''
    #!/usr/bin/env bash
    
    SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$SCREENSHOTS_DIR"
    
    FILE="$SCREENSHOTS_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    
    case "$1" in
      "full")
        grim "$FILE"
        ;;
      "area")
        grim -g "$(slurp)" "$FILE"
        ;;
      "window")
        ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$ACTIVE_WINDOW" "$FILE"
        ;;
      "edit")
        grim -g "$(slurp)" - | swappy -f -
        return 0
        ;;
    esac
    
    if [ -f "$FILE" ]; then
      wl-copy < "$FILE"
      notify-send "Screenshot Saved" "File: $FILE\nCopied to clipboard" -i "$FILE"
    else
      notify-send "Screenshot Failed" "Could not save screenshot"
    fi
  '';
};

# Add keybindings for screenshots
bind = [
  # Your existing bindings
  
  # Screenshots
  "PRINT, exec, ~/.config/hypr/scripts/screenshot.sh full" # Full screen
  "SHIFT+PRINT, exec, ~/.config/hypr/scripts/screenshot.sh area" # Selected area
  "SUPER+PRINT, exec, ~/.config/hypr/scripts/screenshot.sh window" # Active window
  "CTRL+SHIFT+PRINT, exec, ~/.config/hypr/scripts/screenshot.sh edit" # Edit screenshot
];

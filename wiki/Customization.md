---
title: Customization
---

# Customization

This guide explains how to customize your NixOS configuration beyond the default settings.

## Configuration Approach

This configuration uses two primary methods for customization:

1. **Module options**: Enabling/disabling features and customizing behavior through options
2. **Override files**: Creating custom files to replace or extend existing ones

## Customizing Using Module Options

### Basic Option Setting

Most customization happens by setting options in your `home.nix` file:

```nix
userPackages = {
  wm = {
    hyprland = {
      enable = true;
      swaylock = {
        enable = true;
      };
    };
  };
  
  editors = {
    neovim = {
      enable = true;
      plugins = {
        git.enable = true;
      };
    };
  };
};
```

### Finding Available Options

To explore available options:

1. Look at the module source files in the repository
2. Use `home-manager option` commands
3. Check the in-code documentation (option descriptions)
4. Refer to the [Configuration Options](./Configuration-Options) wiki page

Example command to list all options:

```bash
home-manager option userPackages
```

### Setting Complex Options

For more complex options like lists or attribute sets:

```nix
userPackages.media = {
  enable = true;
  audio = {
    enable = true;
    extraPackages = with pkgs; [
      spotify
      audacity
      ardour
    ];
  };
};
```

## Creating Custom Modules

### Creating a Personal Module

1. Create a directory for your personal modules:

```bash
mkdir -p ~/.config/nixos/user/packages/custom
```

2. Create a default.nix file:

```nix
# user/packages/custom/default.nix
{ ... }:

{
  imports = [
    ./myapplication.nix
  ];
}
```

3. Create your custom module:

```nix
# user/packages/custom/myapplication.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.custom.myapplication;
in {
  options.userPackages.custom.myapplication = {
    enable = mkEnableOption "Enable my custom application";
    
    extraPackages = mkOption {
      type = with types; listOf package;
      default = [];
      description = "Additional packages to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ 
      my-main-package
    ] ++ cfg.extraPackages;
    
    # Add any other configuration here
  };
}
```

4. Import your custom module in the main configuration:

```nix
# In profile/personal/home.nix, add to imports:
imports = [
  ../../user/packages
  ../../user/packages/custom  # Add this line
  # ...
];
```

## Customizing Existing Modules

### Overriding Default Values

You can override defaults without modifying the original files:

```nix
# Override the default shell
programs.zsh = {
  enable = true;
  shellAliases = {
    ll = "ls -la";  # Override default
    lh = "ls -lah"; # Add new alias
  };
};

# Override Hyprland keybindings
userPackages.utilities.screenshot = {
  screenKeybinding = ", Print";      # Changed from default
  areaKeybinding = "ALT, Print";
  windowKeybinding = "CTRL, Print";
};
```

### Extending Configuration

You can extend existing configurations:

```nix
# Add additional packages to an existing module
userPackages.development.python = {
  enable = true;
  extraPackages = with pkgs.python3Packages; [
    pandas
    matplotlib
    scikit-learn
  ];
};
```

## Theming and Appearance

### Color Schemes

You can customize the color scheme by setting theme variables:

```nix
# For a module that supports theming
userPackages.wm.waybar = {
  enable = true;
  theme = {
    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    accentColor = "#89b4fa";
  };
};
```

### Fonts

Customize fonts throughout the system:

```nix
userPackages.fonts = {
  enable = true;
  nerdFonts = {
    enable = true;
    firaCode.enable = true;
  };
  systemFonts = {
    enable = true;
    defaultFontFamily = "FiraCode Nerd Font";
    defaultMonoFamily = "FiraCode Nerd Font Mono";
  };
};
```

## Custom Scripts and Tools

### Adding Personal Scripts

1. Create a script file in a custom location:

```bash
mkdir -p ~/.config/nixos/user/packages/scripts/custom
```

2. Create a Nix file for your script:

```nix
# user/packages/scripts/custom/my-script.nix
{ config, lib, pkgs, ... }:

with lib;

let
  myScript = pkgs.writeShellScriptBin "my-custom-tool" ''
    #!/usr/bin/env bash
    
    # Your custom script content here
    echo "Hello, this is my custom tool!"
    
    # You can use other tools installed in your environment
    ${pkgs.htop}/bin/htop
  '';
in {
  config = {
    home.packages = [ myScript ];
  };
}
```

3. Import your script module:

```nix
# user/packages/scripts/custom/default.nix
{ ... }:

{
  imports = [
    ./my-script.nix
  ];
}
```

## Advanced Configuration Techniques

### Conditional Configuration

Apply configuration only when certain conditions are met:

```nix
{ config, lib, pkgs, ... }:

with lib;

let 
  isLaptop = builtins.pathExists /sys/class/power_supply/BAT0;
in {
  config = mkMerge [
    # Base configuration for all systems
    { ... }
    
    # Laptop-specific configuration
    (mkIf isLaptop {
      services.tlp.enable = true;
      services.thermald.enable = true;
    })
  ];
}
```

### Using Overlays

Customize packages using overlays:

```nix
nixpkgs.overlays = [
  (final: prev: {
    myCustomizedPackage = prev.somePackage.override {
      enableFeatureX = true;
      disableFeatureY = true;
    };
  })
];
```

### Using Home Manager Modules

Integrate with Home Manager's own modules:

```nix
programs.alacritty = {
  enable = true;
  settings = {
    font.size = 12;
    window.opacity = 0.95;
  };
};

services.picom = {
  enable = true;
  vSync = true;
  shadow = true;
};
```

## Examples

### Example: Custom Desktop Environment

```nix
# In your home.nix
userPackages = {
  wm = {
    hyprland = {
      enable = true;
      swaylock.enable = true;
      swayidle.enable = true;
      swayidle.timeouts = {
        lock = 300;
        dpms = 600;
      };
    };
  };
  
  utilities = {
    rofi.enable = true;
    clipboard.enable = true;
    screenshot.enable = true;
    powerManagement = {
      enable = true;
      defaultProfile = "balanced";
    };
  };
  
  media = {
    enable = true;
    audio.enable = true;
    video.enable = true;
  };
};

# Add custom keybindings
wayland.windowManager.hyprland.extraConfig = ''
  # Custom application keybindings
  bind = SUPER, F, exec, firefox
  bind = SUPER SHIFT, F, exec, firefox --private-window
  bind = SUPER, D, exec, discord
  bind = SUPER, M, exec, thunderbird
'';
```

### Example: Custom Development Environment

```nix
# In your home.nix
userPackages = {
  development = {
    enable = true;
    
    # Language-specific tools
    python.enable = true;
    nodejs.enable = true;
    rust.enable = true;
    
    # General tooling
    git = {
      enable = true;
      userName = "Your Name";
      userEmail = "your.email@example.com";
      enableCommitTemplate = true;
    };
    
    github.enable = true;
  };
  
  editors = {
    neovim = {
      enable = true;
      plugins = {
        lsp.enable = true;
        git.enable = true;
        languages = {
          python.enable = true;
          javascript.enable = true;
          typescript.enable = true;
          rust.enable = true;
        };
      };
    };
  };
};
```

## Best Practices

1. **Avoid modifying core files**: Use overrides instead
2. **Keep customizations modular**: Create small, focused custom modules
3. **Test changes incrementally**: Make small changes and test frequently
4. **Comment your customizations**: Document why you made certain changes
5. **Use version control**: Commit your customizations to your own branch
6. **Stay compatible**: Try to maintain compatibility with upstream changes
7. **Share improvements**: Consider contributing useful customizations back to the main project

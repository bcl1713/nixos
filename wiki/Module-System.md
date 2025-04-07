---
title: Module System
---

# Module System

This configuration uses a modular approach based on the Nix module system. Understanding how modules work will help you customize and extend your configuration effectively.

## Module Structure

Each module follows a consistent structure:

```nix
# user/packages/example/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.example;
in {
  options.userPackages.example = {
    enable = mkEnableOption "Enable example module";
    
    # More options defined here
    setting1 = mkOption {
      type = types.str;
      default = "default value";
      description = "Description of setting1";
    };
  };

  config = mkIf cfg.enable {
    # Configuration to apply when enabled
    home.packages = with pkgs; [ 
      package1
      package2
    ];
    
    # Other configuration...
  };
}
```

## Key Components

### Options

Options define the customizable parameters for a module. Common option types include:

- **Enable flags**: Toggle features on/off
- **Strings**: Text values for configuration
- **Integers**: Numeric values
- **Booleans**: True/false values
- **Enums**: Selection from predefined options
- **Lists**: Collections of values
- **Attribute sets**: Structured data

Example:

```nix
options.userPackages.browser.firefox = {
  enable = mkOption {
    type = types.bool;
    default = true;
    description = "Whether to enable Firefox browser";
  };
  
  privacy = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable privacy enhancements";
    };
  };
};
```

### Configuration

The `config` section contains the actual implementation that gets applied when the module is enabled. It typically:

1. Is conditional based on the `enable` option
2. Installs packages
3. Sets up configuration files
4. Defines services
5. Configures integration with other components

Example:

```nix
config = mkIf cfg.enable {
  home.packages = with pkgs; [ firefox ];
  
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        settings = mkIf cfg.privacy.enable {
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
        };
      };
    };
  };
};
```

## Module Hierarchy

Modules are organized hierarchically:

```
user/packages/
├── apps/
│   ├── browser/
│   │   ├── default.nix  # Parent module
│   │   └── firefox.nix  # Child module
│   └── terminal/
├── development/
├── editors/
├── scripts/
└── wm/
```

Each directory typically has a `default.nix` file that:
1. Imports all submodules
2. Defines common options
3. Sets up shared configuration

## How to Use Modules

### Enabling/Disabling Modules

In your `home.nix` configuration, you can toggle modules:

```nix
userPackages = {
  apps = {
    browser = {
      enable = true;  # Enable all browsers
      firefox.enable = true;  # Enable Firefox specifically
      chrome.enable = false;  # Disable Chrome
    };
  };
};
```

### Customizing Module Settings

You can customize options for enabled modules:

```nix
userPackages.utilities.screenshot = {
  enable = true;
  screenKeybinding = "CTRL, Print";  # Custom keybinding
  areaKeybinding = "CTRL ALT, Print";
};
```

## Creating Custom Modules

### Step 1: Create the Module File

Create a new `.nix` file in the appropriate directory:

```nix
# user/packages/custom/mycoolfeature.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.custom.mycoolfeature;
in {
  options.userPackages.custom.mycoolfeature = {
    enable = mkEnableOption "Enable my cool feature";
    
    # Your custom options here
  };

  config = mkIf cfg.enable {
    # Your configuration here
  };
}
```

### Step 2: Import the Module

Add your module to the parent module's imports:

```nix
# user/packages/custom/default.nix
{ ... }:

{
  imports = [
    ./mycoolfeature.nix
    # Other imports...
  ];
}
```

### Step 3: Import the Parent Module

Ensure the parent module is imported in the main configuration:

```nix
# user/packages/default.nix
{ ... }:

{
  imports = [
    # Existing imports...
    ./custom
  ];
}
```

## Advanced Module Techniques

### Conditional Imports

You can conditionally import modules:

```nix
imports = with lib; [
  ./base.nix
] ++ (optional config.userPackages.feature1.enable ./feature1-extras.nix)
  ++ (optional config.userPackages.feature2.enable ./feature2-extras.nix);
```

### Module Dependencies

You can create dependencies between modules:

```nix
config = mkMerge [
  (mkIf cfg.enable {
    # Basic configuration
  })
  
  (mkIf (cfg.enable && cfg.advancedFeature.enable) {
    # Additional configuration for advanced feature
  })
];
```

### Module Overrides

You can override default behavior:

```nix
# Override the default terminal
userPackages.apps.terminal.kitty.enable = false;
userPackages.apps.terminal.alacritty.enable = true;
```

## Debugging Modules

To debug module issues:

1. Use `home-manager build --flake .#username` to check for errors
2. Enable verbose output: `home-manager build --flake .#username -v`
3. Inspect option values: `home-manager build --flake .#username --show-trace`

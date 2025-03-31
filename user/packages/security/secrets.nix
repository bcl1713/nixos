# user/packages/security/secrets.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.security.secrets;
in {
  options.userPackages.security.secrets = {
    enable = mkEnableOption "Enable secrets management with sops-nix";

    defaultSopsFile = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.config/sops/secrets.yaml";
      description = "Default SOPS file path";
    };

    age = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use age for encryption";
      };

      keyFile = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        description = "Path to the age key file";
      };
    };

    gpg = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use GPG for encryption";
      };

      keyId = mkOption {
        type = types.str;
        default = "";
        description = "GPG key ID to use for encryption";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install required packages - filtering out null values
    home.packages = with pkgs;
    # Core packages with conditional elements
      ([ sops ] ++ (optional cfg.age.enable age)
        ++ (optional cfg.gpg.enable gnupg) ++

        # Helper scripts
        [
          (writeShellScriptBin "sops-edit-secrets" ''
              #!/usr/bin/env bash
              
              # A helper script to edit the secrets file
              SOPS_FILE=${cfg.defaultSopsFile}
              AGE_KEY_FILE=${cfg.age.keyFile}
              
              if [ ! -f "$SOPS_FILE" ]; then
                echo "Creating new secrets file at $SOPS_FILE"
                
                ${
                  if cfg.age.enable then ''
                          # Use age key if it exists, otherwise create it
                          if [ ! -f "$AGE_KEY_FILE" ]; then
                            echo "Creating age key at $AGE_KEY_FILE"
                            mkdir -p "$(dirname "$AGE_KEY_FILE")"
                            ${pkgs.age}/bin/age-keygen -o "$AGE_KEY_FILE"
                            echo "Age key created. Make sure to back it up securely!"
                          fi

                          # Get the public key
                          AGE_PUBLIC_KEY=$(${pkgs.age}/bin/age-keygen -y < "$AGE_KEY_FILE")
                          
                          # Create initial sops config if it doesn't exist
                          if [ ! -f "$HOME/.config/sops/config.yaml" ]; then
                            mkdir -p "$HOME/.config/sops"
                            cat > "$HOME/.config/sops/config.yaml" <<EOF
                    creation_rules:
                      - path_regex: .*${
                        builtins.replaceStrings [ "/" ] [ "\\\\/" ]
                        cfg.defaultSopsFile
                      }.*
                        age: >-
                          $AGE_PUBLIC_KEY
                    EOF
                            echo "Created SOPS config at $HOME/.config/sops/config.yaml"
                          fi
                  '' else
                    ""
                }
                
                # Create an initial secrets file with a dummy key
                mkdir -p "$(dirname "$SOPS_FILE")"
                cat > "$SOPS_FILE" <<EOF
            # Secrets file - DO NOT commit this file unencrypted!
            # This is an initial placeholder. Replace with your actual secrets.
            dummy_key: placeholder_value
            EOF
                
                # Directly use the age key rather than relying on config
                ${
                  if cfg.age.enable then ''
                    ${pkgs.sops}/bin/sops --encrypt --age $(${pkgs.age}/bin/age-keygen -y < "$AGE_KEY_FILE") --in-place "$SOPS_FILE"
                  '' else ''
                    # For GPG
                    ${if cfg.gpg.enable then ''
                      ${pkgs.sops}/bin/sops --encrypt --pgp ${cfg.gpg.keyId} --in-place "$SOPS_FILE"
                    '' else ''
                      echo "Error: No encryption method enabled"
                      exit 1
                    ''}
                  ''
                }
              fi
              
              # Edit the secrets file
              ${pkgs.sops}/bin/sops "$SOPS_FILE"
          '')
        ]);

    # Create necessary directories
    home.activation.setupSopsDirectories =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${dirOf cfg.defaultSopsFile}
        ${if cfg.age.enable then
          "$DRY_RUN_CMD mkdir -p ${dirOf cfg.age.keyFile}"
        else
          ""}
      '';

    # Add sops-nix documentation
    home.file.".config/sops/README.md".text = ''
      # Secrets Management with sops-nix

      This directory contains the configuration for secrets management using sops-nix.

      ## Usage

      ### Editing Secrets

      To edit your secrets file:

      ```bash
      sops ${cfg.defaultSopsFile}
      ```

      ### Accessing Secrets

      In your Home Manager configuration, you can access secrets using the `sops.secrets` option:

      ```nix
      sops.secrets.example-secret = {
        sopsFile = config.userPackages.security.secrets.defaultSopsFile;
      };
      ```

      Then you can reference the secret in your configuration:

      ```nix
      programs.some-program = {
        passwordFile = config.sops.secrets.example-secret.path;
      };
      ```

      ## Key Management

      ${if cfg.age.enable then ''
        ### Age Keys

        Your age key is stored at: ${cfg.age.keyFile}

        To create a new age key:

        ```bash
        age-keygen -o ${cfg.age.keyFile}
        ```

        Make sure to back up this key securely!
      '' else
        ""}

      ${if cfg.gpg.enable then ''
        ### GPG Keys

        Your GPG key ID is: ${cfg.gpg.keyId}

        Make sure this key is in your keyring and has a valid secret key.
      '' else
        ""}
    '';

    # Add bash/zsh completion for sops
    programs.bash.enable = mkDefault true;
    programs.bash.initExtra = mkIf config.programs.bash.enable ''
      # SOPS completions
      if command -v sops &>/dev/null; then
        source <(sops completion bash)
      fi
    '';

    programs.zsh.enable = mkDefault true;
    programs.zsh.initExtra = mkIf config.programs.zsh.enable ''
      # SOPS completions
      if command -v sops &>/dev/null; then
        source <(sops completion zsh)
      fi
    '';
  };
}

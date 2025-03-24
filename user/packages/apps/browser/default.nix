# user/packages/apps/browser/default.nix

{ config, lib, ... }:

with lib;

let cfg = config.userPackages.apps.browser;
in {
  options.userPackages.apps.browser = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable browser applications";
    };

    firefox = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Firefox browser";
      };

      privacy = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable privacy enhancements for Firefox";
        };

        disableTelemetry = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to disable telemetry in Firefox";
        };

        disablePocket = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to disable Pocket in Firefox";
        };

        disableAccounts = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to disable Firefox accounts";
        };

        dnsOverHttps = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable DNS over HTTPS";
          };

          providerUrl = mkOption {
            type = types.str;
            default = "https://dns.quad9.net/dns-query";
            description = "Provider URL for DNS over HTTPS";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.firefox.enable {
      programs.firefox = {
        enable = true;
        policies = mkIf cfg.firefox.privacy.enable {
          DisableFirefoxAccounts = cfg.firefox.privacy.disableAccounts;
          DontCheckDefaultBrowser = true;
          PasswordManagerEnabled = false;
          DisableMasterPasswordCreatioin = true;
          OfferToSaveLogins = false;
          DisablePocket = cfg.firefox.privacy.disablePocket;
          DisableTelemetry = cfg.firefox.privacy.disableTelemetry;
          EncryptedMediaExtensions = { Enabled = false; };
          DNSOverHTTPS = mkIf cfg.firefox.privacy.dnsOverHttps.enable {
            Enabled = true;
            ProviderURL = cfg.firefox.privacy.dnsOverHttps.providerUrl;
            Locked = false;
          };
        };
      };
    })
  ]);
}

# usr/app/firefox/firefox.nix

{ ... }:

{
  programs = {
    firefox = {
      enable = true;
      policies = {
        DisableFirefoxAccounts = true;
        DontCheckDefaultBrowser = true;
        PasswordManagerEnabled = false;
        DisableMasterPasswordCreatioin = true;
        OfferToSaveLogins = false;
        DisablePocket = true;
        DisableTelemetry = true;
        EncryptedMediaExtensions = {
          Enabled = false;
        };
        DNSOverHTTPS = {
          Enabled = true;
          ProviderURL = "https://dns.quad9.net/dns-query";
          Locked = false;
        };
      };
    };
  };
}

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
      };
    };
  };
}

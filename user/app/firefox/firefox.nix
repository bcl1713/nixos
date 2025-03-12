{ config, pkgs, ... }:

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

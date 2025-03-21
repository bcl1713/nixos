# user/app/nextcloud/nextcloud.nix
{ pkgs, lib, ... }:

{
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
  
  # Override the systemd service configuration
  systemd.user.services.nextcloud-client = {
    Unit = {
      After = lib.mkForce ["graphical-session.target" "network.target"];
      Requires = lib.mkForce ["graphical-session.target"];
      PartOf = lib.mkForce ["graphical-session.target"];
      Description = lib.mkForce "Nextcloud desktop client";
    };
    Install = {
      WantedBy = lib.mkForce ["graphical-session.target"];
    };
    Service = {
      # Add a short delay to ensure everything is ready
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
  
  home.packages = with pkgs; [
    nextcloud-client
  ];
}

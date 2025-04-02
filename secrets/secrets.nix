# ~/.secrets/secrets.nix
let
  brianl =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5qNdejFu9ZkCETvDyWh8o3otOh06Ojq70l0XJ5YfBw";
  nixbook =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJtINTDLcT4InI3X3/6CGjgZT/KbUuJYTZLGtFiuNZw";

  allUsers = [ brianl nixbook ];
in {
  # Define your secrets here
  "personal-email.age".publicKeys = allUsers;
}

# profiles/personal/secrets.nix
{ ... }: {
  age = {
    identityPaths = [ "/home/brianl/.ssh/id_ed25519" ];

    secrets = {
      personal-email = {
        file = ../../secrets/personal-email.age;
        owner = "brianl";
        group = "users";
        mode = "0400";
      };
      tailscale-auth-key = {
        file = ../../secrets/tailscale-auth-key.age;
        owner = "brianl";
        group = "users";
        mode = "0400";
      };
    };
  };
}

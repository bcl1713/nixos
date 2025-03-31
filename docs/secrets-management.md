# Secrets Management with sops-nix

This guide explains how to use the secrets management system in this NixOS configuration.

## Overview

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) for managing secrets. SOPS (Secrets OPerationS) allows you to encrypt your secrets with either age or GPG, and then use them securely in your NixOS configuration.

## Getting Started

### 1. Enable Secrets Management

First, enable the secrets management module in your `home.nix`:

```nix
userPackages.security.secrets = {
  enable = true;
  # Default configuration uses age encryption
};
```

### 2. Apply Configuration

Apply your configuration with:

```bash
home-manager switch --flake .#brianl
```

This will install the required tools and create a helper script.

### 3. Initial Setup

Run the helper script to set up your encryption keys and secrets file:

```bash
sops-edit-secrets
```

This will:
- Create an age key pair (if using age encryption)
- Set up the SOPS configuration file
- Create an initial encrypted secrets file
- Open the secrets file for editing

### 4. Backing Up Your Keys

**IMPORTANT**: Back up your encryption keys immediately after creation!

For age encryption, back up the file at:
```
~/.config/sops/age/keys.txt
```

Store this backup in a secure location such as a password manager or encrypted storage.

## Managing Secrets

### Editing Secrets

To edit your encrypted secrets file:

```bash
sops-edit-secrets
```

This opens the decrypted file in your editor. When you save and exit, the file is automatically re-encrypted.

### Secret Format

Secrets are stored in YAML format:

```yaml
# Top-level key-value pairs
api_token: "secret-token-value"

# Grouped secrets
database:
  username: "db-user"
  password: "db-password"

# Multiple environments
production:
  api_key: "prod-key"
development:
  api_key: "dev-key"
```

## Advanced Configuration

### Using GPG Instead of age

To use GPG for encryption:

```nix
userPackages.security.secrets = {
  enable = true;
  age.enable = false;
  gpg = {
    enable = true;
    keyId = "YOUR_GPG_KEY_ID"; # Replace with your GPG key ID
  };
};
```

### Custom Paths

You can customize the paths for your secrets file and key storage:

```nix
userPackages.security.secrets = {
  enable = true;
  defaultSopsFile = "~/.secrets.yaml"; # Custom secrets file location
  age = {
    enable = true;
    keyFile = "~/keys/sops-key.txt"; # Custom key file location
  };
};
```

## Security Best Practices

1. **Never commit unencrypted secrets** to your Git repository
2. **Back up your encryption keys** in a secure location
3. **Regularly rotate your secrets** following security best practices
4. **Limit access** to your encryption keys to only those who need them
5. **Use different keys** for different environments or sensitivity levels

## Troubleshooting

### "No key found" Error

If you get an error about no key being found:
- Check that your age key file exists at the configured location
- Ensure the key file has the correct permissions (readable by your user)
- Verify that the public key in the SOPS config file matches your key

### Lost Private Key

If you lose your private key:
- You will not be able to decrypt your secrets file
- You'll need to create a new key and re-encrypt your secrets
- This is why backing up your keys is critical

## Resources

- [SOPS GitHub Repository](https://github.com/mozilla/sops)
- [sops-nix GitHub Repository](https://github.com/Mic92/sops-nix)
- [age Encryption Tool](https://age-encryption.org)

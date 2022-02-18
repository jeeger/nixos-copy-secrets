# NixOS copy secrets module

This is a very simple module that copies files into their destination before running a service.

# Usage examples

```nix
  services.copy-secrets = {
    enable = true;

    secrets.deluged = {
      secrets.auth = "/etc/secrets/deluge-auth";
      owner = config.services.deluge.user;
      group = config.services.deluge.group;
    };
```

This copies `/etc/secrets/deluge-auth` to `/etc/deluge/auth`, accessible only as the user the deluge service runs as.
    
```nix
   secrets.prometheus = {
      owner = "prometheus";
      group = "prometheus";
      secrets.ca = "/etc/pki/pki/ca.crt";
      secrets.cert = "/etc/pki/pki/issued/prometheus.ogion.thenybble.de.crt";
      secrets.key = "/etc/pki/pki/private/prometheus.ogion.thenybble.de.key";
    };
  };
```

Multiple secrets can be copied.

# Implementation

The module is implemented by generating a systemd service that copies the files, and marking it as a requirement of the service. When the service is started, the "<service>-copy-secret" unit is started first, copies the file, and the new service finds the secrets where it expects them to be.

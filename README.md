# NixOS copy secrets module

This is a very simple module that copies files into their destination before running a service.

# Usage example

```nix
  services.copy-secrets = {
    enable = true;

    secrets.deluged = {
      secrets.auth = "/etc/secrets/deluge-auth";
      owner = config.services.deluge.user;
      group = config.services.deluge.group;
    };

    secrets.grafana = {
      owner = "grafana";
      group = "grafana";
      secrets.auth = "/etc/secrets/grafana-auth";
    };

    secrets.prometheus = {
      owner = "prometheus";
      group = "prometheus";
      secrets.ca = "/etc/pki/pki/ca.crt";
      secrets.cert = "/etc/pki/pki/issued/prometheus.ogion.thenybble.de.crt";
      secrets.key = "/etc/pki/pki/private/prometheus.ogion.thenybble.de.key";
    };
  };
```

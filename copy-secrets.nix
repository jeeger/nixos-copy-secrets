{lib, pkgs, config, ...}:
with lib;
let
  cfg = config.services.copy-secrets;
  secretTypes.serviceConfig = types.submodule {
    options = {
      secrets = mkOption {
        description = "Which secrets to prepare for this service.";
        type = types.attrs;
        default = {};
        example = literalExpression ''
          {
            auth = "/etc/secrets/secretfile";
          }
        '';
      };
      owner = mkOption {
        type = types.str;
        description = "Owner of secret";
      };
      group = mkOption {
        type = types.str;
        description = "Group of secret";
      };
    };
  };
  makeService = service: {secrets, owner, group}:
    let
      directoryName = "/etc/${service}";
      copyCommands = concatStringsSep "\n"
        (attrValues
          (mapAttrs
            (secretName: secretSource: "cp ${secretSource} ${directoryName}/${secretName}") secrets));
    in
      {
        name = "${service}-copy-secrets";
        value = {
          description = "Copy secret(s) for ${service}";
          requiredBy = [ "${service}.service" ];
          script = ''
            mkdir -p ${directoryName}
            ${copyCommands}
            chown -R ${owner}:${group} ${directoryName}
            chmod 500 ${directoryName}
            chmod -R 400 ${directoryName}/*
          '';
        };
      };
  makePaths = {service, secrets, ...}: {
    
  };
in {
  options.services.copy-secrets = {
    enable = mkEnableOption "secrets service";
    secrets = mkOption {
      type = types.attrsOf secretTypes.serviceConfig;
      description = "Service name to secret config";
      default = {};
    };
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' makeService cfg.secrets;
  };
}

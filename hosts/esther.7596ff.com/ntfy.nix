# Use `ntfy user` and `ntfy access` to manage users; make sure to
# run it as the ntfy-sh user (i.e. `sudo -u ntfy-sh ntfy ...`)
{ config, ... }:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.somas.is";
      behind-proxy = true;

      auth-default-access = "deny-all";
      enable-login = true;
      enable-reservations = true;
    };
  };

  services.nginx.virtualHosts."ntfy.somas.is" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      # Follow <https://docs.ntfy.sh/config/#nginxapache2caddy> instructions
      proxyPass = "http://${config.services.ntfy-sh.settings.listen-http}";

      extraConfig = ''
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout 3m;
        proxy_send_timeout 3m;
        proxy_read_timeout 3m;

        client_max_body_size 0; # Stream request body to backend
      '';
    };
  };

  persist.directories = [
    {
      directory = "/var/lib/private/ntfy-sh";
      user = "root";
      group = "ntfy-sh";
      mode = "0770";
    }
  ];
}

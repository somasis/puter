{ pkgs
, lib
, config
, self
, ...
}:
let
  # hledgerWebSocket = "/run/hledger-web/hledger-web.sock";

  ircHome = "/var/lib/irc";

  cert = {
    litterbox = ''
      subject=CN = client-litterbox
      -----BEGIN CERTIFICATE-----
      MIIEvTCCAqUCFDTaXnVkwk0m41gZFHjwy1jqU99DMA0GCSqGSIb3DQEBCwUAMBsx
      GTAXBgNVBAMMEGNsaWVudC1saXR0ZXJib3gwHhcNMjAwODEwMjEzNTQ1WhcNMzAw
      ODA4MjEzNTQ1WjAbMRkwFwYDVQQDDBBjbGllbnQtbGl0dGVyYm94MIICIjANBgkq
      hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApQprxetdI3UnDOkNMzFvqruyf3ktfPmw
      5yWtXpxbhj2ioJAu9T5bbwWRRX1XRTC6gV1rUk5k8BHXVRw7j9q2DdO72ztGkROb
      OnVH6imuESPAr58y/945MWM4RDzV/goPC3F8D/5lWFRvYkm1M0v7RyVg/R8OYOfq
      xUeP7Y2/NSfOwkzGVdLAqGsenM3h+yQREBP3Kiqb0mr5KxBruRPxFKoaguVaKKVV
      niqkz+SH3tvbJQ4NsoWvKifgGkUGy9Ow7be0ywsv4xw8WzfcDpPdiha4Mb0AGYYI
      4RQIIuyTdd10iT+VGXu8Uf1CA7X4xW/6tGfydnwuf8+MemMndZ841x5rIdskdzxj
      wzrfdNGktd9QrIwrBctdpqUuLlYUofNXinBcZcn3/gVSwuSBABrGZknVloYg5Tfp
      ZAPBTchwHu+nznQ188SC0OXLIdJ5o822Dv+xa2LnnAwDa9YY5zKdzAm7CZLO/k3U
      UpYOjDd8ZMChbfeq4uBAMFZuOt8hUwS4H9B90MJEVcjMBkftlYMRkSLzFx0uI8nb
      4vzfBat9LlYNVKZ/YB9p1YgFrK6uNGrBZPxNdit3KOEKJ3KF9Z13qm+MxIK9TYWA
      FmPJHea31FFExI0n37Shh26e1vE1WokJwyMdKdl687rhB73RkOch3kp8c732PuZZ
      xM+BbDGVbJUCAwEAATANBgkqhkiG9w0BAQsFAAOCAgEAiN6L3AzS214Ki+IoGt03
      4wQ/mFJFi8DJ8Ys84P2d5Y87HGHJY9sIySkGD1iS674+R/R2Qx1fxNibh9mmdC2U
      gFEYE1JjurKrjAkoLbP+c7yaWhMxn4RqmkF43ndetj8OWfHkZS9axNW2NLiG4vhJ
      4FJvkS5A4LpbcP3UtsDbW96knFbriDe+CrmfV3Aa4BnqAdqEC9dGU0OmfjrP87oo
      iWKkYo8Ui5LWDgZyBH9f3/gQ3q2csQ8pyT4pFeT0XCXnNovuWaA2s2WaZtGyos0z
      3bmAd3ZmOuWpIen0ozyfGzY61jqSZiGKKaDQ6FDL/Ci+dTDVda8XuaN5xEn+0pa8
      H5mMsZyvXDwYjJ2YW7a8qLKUL5+HTOfGxFma5c1fHoIJ32CYozYSFiaCxfl5vNQh
      hF97FjU2PnlDHtLLpCtR5/+IgtWRYtNLefd4z0Xt+dAyVChSkZ/lbuHUK3T0qyp1
      +/e08aB20oZiWyfh77CqlYA1Mu1RjSypFdnLFiT7Ozo3nZ5HxgOjJ99J7V0f9mwr
      XZJjoWcHMww2tBwlYeAYv6GaFnxtUDrRJrM4dyyhlFBxfVx94ZJzGfklmssRbEhK
      Ot5Ra2XEjut0g+fB7HTwSjBX8Xu8ubRD4cAMs9dISj+fBWHsBqvyFnPZ1dLY9fjV
      4MBIGVYIgQg8FTzezEb9SYc=
      -----END CERTIFICATE-----
    '';

    "ilo.somas.is" = ''
      subject=CN = client-ilo.somas.is
      -----BEGIN CERTIFICATE-----
      MIIEpjCCAo4CCQDDoLudILnAtjANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApj
      bGllbnQtaWxvMB4XDTIyMDUyNzIzNTE0NVoXDTMyMDUyNDIzNTE0NVowFTETMBEG
      A1UEAwwKY2xpZW50LWlsbzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
      ANx0Z06l4SLqqSTA6bfIMRLOmezHQTAwx0OKqNS3bKljrIhOWhy908dd0Debb+HK
      osYFy1rhdas9gBSkk2FLIarnffZ2hBJADlgJj4jvGKHxNd3/Flw8lTJ4N+/hx4j6
      5bExSdixexHFyFIElQHH1fH7upEBLNDHl8TekfM+YPU+dAVyj0WagG2TxMjx0Fay
      VhjiyMW7x1ajb9x83/Cf8XBzLYb8Ho/TyUJQbWJMmRi9izDDc9HlIK7jUlY3n0X8
      70NUyO8w7WZk4SrKBeAQDDQDZ2TgUGtAxn7LhNYPXRphpIS4L+jQCqVNclPQfIhQ
      lOQGcVCuHZcDr/MRerJ7rFiKQAL5Os2plcQ3lXpaT14rXY5f7RYdEo1iO6zaaaye
      bmcyzlyeaFYZo9SL3940N5CVfRvCizvCPOnW6x/ERZ/VYw5Yqbb7mVNGPYUpH76R
      Bi5iCk4/JCSxNhEpJxg2nFE2NUp5cKfQbVua7lsEsmzcEh5k8N6eWXE19sRhXGIH
      CgYgGvAJZvSypiSaONydsW0BLRhD53Obkz+uzfx6ml+LaZ5dQOVBgHvYVAvX25xQ
      BUz/KXdeO3S+eFxwFrl9TXhHtqvNVDMLZfC3cmGMfg6VZDagJHf1a75TYxu/FbKg
      WzBnY+5NxFdsjSaDMd5XerNtXT3JwWZGzYoE/EpKEGD5AgMBAAEwDQYJKoZIhvcN
      AQELBQADggIBAEIViNgqBbuhZWIYgqEJmYMctDMTRpzTxqgw63PLtfv0ae1AmaXx
      7czppkbB4OfP53ocSB8z5/Yqd9VTPkvIkeJlGGNNSscYLZV6X6OmjbZHW2yV+Zbx
      52o1iI73G86OBpxmRCLOY13pY2pQy6VQTDk5zXQ/gNp157LH0NcQZbHBIpDzbGcv
      HxvVv85wcJiW0DgXDi5KJjNx7OJ6GVpckDzbUVLJGbi4hhLs6tX94ywBcWBVSFGG
      zsYz/VpWOUTyYH1LPRnAS3M45bhrc4jnKYXDqGCv06sFTT0KYLhi3ESXN9+Lcmy+
      cJJnefDFPol4p2eRncKtkhHF+mVE7C3B3uuQ3wUdZB1qOBzWRqXGI1gcPmQ21dPU
      ogJ38P+xGuCKJSHpFm7IZgEkKQc27tdmtUIeccYTaY+EzUc35clxpsVYEOJ0vBcM
      +aGK20VV4v4O/RPVm49PhbSTizJ89VWOnQxvVhTTMBxyAg2LH//cEBUAB1h1d7eB
      xhrCXslJZ9z6u3RVytfUFY2v4/zvOKmn+QMq3Uilvp+A54rwkQVQYd5M4Po8UWni
      Xh67bRPCgP7YbTk0NT920+m2x8wEFgD82B+CLrLDoD6+jYZG/5i9UyfhSDCF2J3T
      25b1uduzGzsBYvnomnbIBRCj4t4FcoTVRsi1/AgVa6zj6W7x597DCoKL
      -----END CERTIFICATE-----
    '';

    "esther.7596ff.com" = ''
      subject=CN = client-esther.7596ff.com
      -----BEGIN CERTIFICATE-----
      MIIEqTCCApECFFFu98rNvejVpEYCJKySr9/Bqh2jMA0GCSqGSIb3DQEBCwUAMBEx
      DzANBgNVBAMMBnBvdW5jZTAeFw0yMTA0MDQxOTUzNDFaFw0zMTA0MDIxOTUzNDFa
      MBExDzANBgNVBAMMBnBvdW5jZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
      ggIBAKu5jMbW3AU1/fov8v4R2wxDvmSyavdUeQ3sG+Xi5e1BfAPI9e4geAvmnzeY
      Hw2FiUpl8uEZcZiN5TiB4dHplnU9PY5dqv+sSSgL9rU9nIeipl6t8gsbt3mNr3jU
      egUOQGdEm3bUWX1KTLbc/IUSy5McmIYTI70HdmkbC7tF3s2VtLFI9PnuSMpda3Rl
      qJh8QUoS46MPj6oFuQKWZuNn1NXljRK0BlJ1VH+NeGGVRdf97svkN9RhTSngODi1
      Q7+f51ZGe+Fj+cA4I5Dve+L0jg34F1Q4SDk6US8JuKn1V7CbVw8VlD0X08Ryn16T
      0ZVHjo3Nz7mE7oGQX0yq7ZxUuou6N8O7BeW6E6YkTgKUCxTr5gGFc95tBtQIrWrR
      qWgXTyM1CQWYANNBvka08Yh8HCXGiUOyrBml/16S4PuPUz4MJcZypWuAOjAg8lCk
      yB2py3JOQyc8fFO6U1J2tA4hY3E5krSpdJEFVG9LWMVnIo/NxvLP5diOfhYjQeAn
      aKcFczAzezR5IPhoAcP8WVTPCV3e1jVdyTsNekCIIj3kKtQzrNXFXwBslp2Nf1OE
      F8aeYl+HYcM7W3oX/b69z/tzQpTYDOdJLQ9Z0R3doEUkQrpJKXTxUppMzrUZkIK1
      Kul7TdICLUVnc8+j4FWOHXxvmQ9Ze74tteTnQUn2eiTg5K8JAgMBAAEwDQYJKoZI
      hvcNAQELBQADggIBAJaW6G6XkrRar7BBXyqBI79oblwjg15w+8x7FwvXyW8D21Fj
      +Yc+4PluT+MptKMTBM2a1tctQxaZXWg2WjN23rdwS6szOtcg9idpBViSrMKGN8pK
      HHZwtVKqrO7xLbloDy5y+9LyJthibf55/wvbjAZb67o6kJdWcZ61U9ul+KkUhyXU
      NI8snBf1UnCnoahABCeOKY5EE+WqubliZHA6UrN8jtXpfG0aS07/Ivw2/ydDaBPQ
      dQlp+wztApFnAYWIyuegb7n9c38pfZfXNdmLqx9F6etH02Pz5ZixxxiwXjuXd0pR
      tUzjkyHpmemc+8c/rujQQWZBMvHt9WO8N65YXBC9YxNSL/yBv8m23cYc0iMVZXpp
      vD3S1YdzRBZcUcFoGAXaj8wYUrOANbvxFvt48kAGYepDZUTxudfi1/2eBuiZqcTK
      O027kdeKBYtPdMDUmHDaP/fEYM8qH7Ddqvc4MRnY1ZG2FLYPJHyWYcIdVI2PaJHO
      XvW+KDZKKCI3pO1SKgXSAazLFHOWgKD+1wXI85G41fJtJf+XGOry+xx0OUBigl1K
      oooNcQ57eW1YJiqLX5gowbYSuxTovp3EcHQjZukn+q5ZazGi/QYUngMfWhOZ12Qd
      ppPkoVS6jXx0WXHfKgIS04xOrtUIc4LlaRNdD/gRSgydzWnSMe8mKFOw0XZn
      -----END CERTIFICATE-----
    '';

    "phone.somas.is" = ''
      subject=CN = client-phone.somas.is
      -----BEGIN CERTIFICATE-----
      MIIEqjCCApICCQD54AOUfWxccTANBgkqhkiG9w0BAQsFADAXMRUwEwYDVQQDDAxj
      bGllbnQtcGhvbmUwHhcNMjQxMTA0MTQzNDI2WhcNMzQxMTAyMTQzNDI2WjAXMRUw
      EwYDVQQDDAxjbGllbnQtcGhvbmUwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
      AoICAQDAvNfT5e9o4lHT604W+BQMkK1Ak44sTiWQYJAe/DgUJ/a3uhJZHpzmfSKJ
      0X4yyQlGN/hzxlcWXZo+/2EAcT0IHopXVuwL3IvCJCGSG32Zvamits3mOmXSQV5A
      NmYnmv1KFSCzBdeQfiBewZwCHrnBYebec5Mhpu9cfg4esBP9dcgTgFCml7znVB2/
      ckz+MLDj9sUw6vPvbTEvuJLbFrg+1JrKB+jG4wXV4SgTOsnC7DQClKwbdgTn5t6K
      H2O8ZtvV+y9nGu2L4zHrGcClJrebZ7t6y9i63rQWiOY/2snLRMGvzMhCN71POZDJ
      1J/UdZls8UxyJtkQ1+imGxFfwKzGrBPtN6e79oVfKL3y/Y3YbBs4HbzH2w+scYDJ
      SHs2Y+Ikbh8c98P+/Ev/P2WQaEn6y8t1ZNIJycir0cz+pUlfnyf2wXmjiprUVzbi
      AuNzWdlbwjarXcQPVg1Zz6hS5SylBUd70FF+6hYxhd2lwiH/PWCykuEVceQDlpV6
      TmGmUx5gFwkZ04aIlmzvfFagNrf0x5E8zkA6+sMWw323MZVEOAtx0BPEVxxxIBhC
      JzQBiyeJZ5BjAD/sAoy227AP8gCNGi6T8YlIIsUcLHBLsCvM8drrWt/LEjwQ/shm
      m5Lqt7vYIPjXLp8WoUdkz4GBAjFOSIL+lwNzS3HFpwGgbzwA5QIDAQABMA0GCSqG
      SIb3DQEBCwUAA4ICAQBhUxvCBpoz7Tjn+w05qFcG9Ix8ur/8EOjshbgPdPUO8FUW
      idtn44EIbWKT/SRX9CoUnO5G26Sdgs5kMDjhP01e8i0pWQ8YaOwpFDMKJD/EVjlx
      piD4Q30AlFXf40xyiwyKqxgwGEr3IY1JAgkc+7W2YNb4BqBFVPQOdCV8Xb3yRszP
      L9PyR1pOPftufith8ZsAHNyxAw4DlCsn5ZEexl+ItC8axOq7QEDKb9wGTLSdOQ8W
      Jy3kX949oE7FCUoGfZ7k+CRcrGMAsFxDyXVjXmTl/kAQ5upfPF9l31ZgMNLL7YMb
      ThE0fiUr9qlhKeoBCmlYQexitqthoARQ0ukvnW1XhkHFJTg4jvjJl6d5aeMJDFZi
      mHcNHQbEDpT3S98gb4dS1ASBrvfGQ2A7aR3xz66ojrBKpoKE7Or01u0ZmsjzzzDe
      5snuhgHO5CwFWb2ofeZARWLeI+legICCMgijFcR2iPeDVPHcG35BTFV080D9IX2+
      nmaSkI94OaYwBlheoIfwPOoF0bUl2T4rLgR/LylFMkOZ3k7OI55H4vHLKZZDYCSs
      2MH49VHe0Dz942DszrRkhhfr9Y/4FYxfcJu7yYUGcty7x5v3241SiBoXrPh5lobi
      H0siNBUBkUoLb2GtNgBp14MX5Czu3/qv/atQwQMUpgwKaRC6wO7/XxTOrhYm6w==
      -----END CERTIFICATE-----
    '';
  };
in
{
  age.secrets = {
    somasis-htpasswd-scooper = {
      file = "${self}/secrets/somasis-htpasswd-scooper.age";
      owner = "irc";
      group = "irc";
    };
  };

  persist.directories = [
    {
      directory = "${ircHome}";
      user = "irc";
      group = "irc";
      mode = "0770";
    }
  ];

  users = {
    users.irc = {
      isNormalUser = false;
      isSystemUser = true;

      description = "IRC services";

      home = ircHome;

      group = "irc";

      linger = true;
    };

    groups.irc = { };

    users.somasis.extraGroups = [
      "adbusers"
      "irc"
      "gamemode"
    ];
  };

  security.acme = {
    defaults.reloadServices = [
      "pounce@tilde.pounce.somas.is"
    ];

    certs = {
      # "ledger.somas.is" = { };

      "pounce.somas.is" = {
        extraDomainNames = [
          "tilde.pounce.somas.is"
        ];

        postRun = ''
          cp fullchain.pem ${ircHome}/pounce.somas.is.pem
          cp key.pem ${ircHome}/pounce.somas.is.key
          chmod 600 ${ircHome}/pounce.somas.is.{pem,key}
          chown irc:irc ${ircHome}/pounce.somas.is.{pem,key}
        '';
      };
    };
  };

  users.users.nginx.extraGroups = [
    "acme"
    "irc"
    "somasis"
  ];

  environment = {
    systemPackages = [
      pkgs.pounce
      pkgs.litterbox
      pkgs.catgirl
    ];

    etc = {
      "xdg/pounce/tilde.pounce.somas.is.conf".text = ''
        # for clients connecting to pounce
        local-host = tilde.pounce.somas.is
        local-cert = ${ircHome}/pounce.somas.is.pem
        local-priv = ${ircHome}/pounce.somas.is.key
        local-ca = /etc/xdg/pounce/clients.pem

        # `pass esther.7596ff.com/pounce`; workaround for shitty Android IRC clients
        local-pass = $6$kXiQtK3NN/oYnRzT$l6FsG9d6FycRjkEzdRSRm7nYj.AlXx05qAqg8OJVQwXsIKs53iUJe.7Qzq.qd6.9m7uNLeyV4kw.WxIOA7xXD0

        # for pounce's connection to network
        sasl-external
        client-cert = ${ircHome}/client-esther.7596ff.com.pem

        # save backlog buffers for sending to connecting clients
        save = ${ircHome}/tilde.pounce.somas.is.save

        # network
        host = tilde.chat

        nick = kylie
        user = somasis
        real = Kylie McClain <kylie@somas.is> (it/she)

        away = imagine a dog curled up in a bed
        quit = scurries away

        join = #nsfw,#ascii.town
      '';

      "xdg/pounce/clients.pem".text = lib.concatStrings [
        cert.litterbox
        cert."esther.7596ff.com"
        cert."ilo.somas.is"
        cert."phone.somas.is"
      ];

      "xdg/litterbox/tilde.pounce.somas.is.conf".text = ''
        private-query
        limit = 50

        cert = ${ircHome}/client-litterbox.pem
      '';
    };
  };

  systemd = {
    tmpfiles.settings.calico."/run/calico".d = {
      group = "irc";
      user = "irc";
      mode = "0775";
    };

    services."pounce@" = {
      description = "IRC bouncer";
      wants = [ "calico.service" ];
      before = [
        "litterbox@%i.service"
        "calico.service"
      ];
      after = [ "network.target" ];

      startLimitBurst = 10;
      startLimitIntervalSec = 5;

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
        User = "irc";
        Group = "irc";
      };

      environment = {
        XDG_CONFIG_HOME = "/etc/xdg";
        XDG_DATA_HOME = ircHome;
      };

      path = [ pkgs.pounce ];

      script = ''exec pounce "$@"'';
      scriptArgs = "-U %t/calico/ -f ${ircHome}/%i.log %i.conf";
      # -H %i -U %t/calico/

      restartTriggers = [
        config.environment.etc."xdg/pounce/tilde.pounce.somas.is.conf".source
      ];

      reload = "${pkgs.procps}/bin/kill -USR1 $MAINPID";
      reloadTriggers = [ config.environment.etc."xdg/pounce/clients.pem".source ];
    };

    services.calico = {
      description = "TLS connection dispatcher";
      after = [ "network.target" ];

      serviceConfig = {
        User = "irc";
        Group = "irc";
      };

      path = [ pkgs.pounce ];

      script = ''exec calico "$@"'';
      scriptArgs = "-H 0.0.0.0 %t/calico/";
    };

    services."litterbox@" = {
      description = "IRC logger";
      upheldBy = [ "pounce@%i.service" ];
      requires = [ "pounce@%i.service" ];
      after = [
        "network.target"
        "pounce@%i.service"
      ];

      startLimitBurst = 10;
      startLimitIntervalSec = 5;

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
        User = "irc";
        Group = "irc";
      };

      environment = {
        XDG_CONFIG_HOME = "/etc/xdg";
        XDG_DATA_HOME = ircHome;
        LITTERBOX_DB = "${ircHome}/litterbox.sqlite";
      };

      path = [ pkgs.litterbox ];

      script = ''
        if ! [ -e "$LITTERBOX_DB" ]; then
            litterbox -d "$LITTERBOX_DB" -i
        else
            litterbox -d "$LITTERBOX_DB" -m
        fi

        exec litterbox "$@"
      '';
      scriptArgs = "-d \${LITTERBOX_DB} -h %i %i.conf";
    };

    targets.irc = {
      wants = [
        "pounce@tilde.pounce.somas.is.service"
        "litterbox@tilde.pounce.somas.is.service"
      ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };
  };

  # systemd.services.scooper = {
  #   wantedBy = [ "nginx.service" ];
  #   before = [ "nginx.service" ];

  #   environment = {
  #     inherit (config.systemd.services."litterbox@".environment) LITTERBOX_DB;
  #     SCOOPER_SOCKET = "/run/scooper/scooper.sock";
  #   };

  #   serviceConfig = {
  #     inherit (config.systemd.services."litterbox@".serviceConfig) Group;
  #     RuntimeDirectory = "scooper";
  #     UMask = "002"; # create socket with group readability so nginx can access it
  #   };

  #   # confinement = {
  #   #   enable = true;
  #   #   packages = [ kcgi scooper ];
  #   #   mode = "chroot-only";
  #   # };

  #   # FIXME(somasis): do the chroot correctly

  #   restartTriggers = [ pkgs.scooper ];

  #   path = [
  #     pkgs.kcgi
  #     pkgs.scooper
  #   ];

  #   script = ''
  #     exec kfcgi -d \
  #         -u ${config.services.nginx.user} \
  #         -s "$SCOOPER_SOCKET" \
  #         -U ${config.systemd.services."litterbox@".serviceConfig.User} \
  #         -p / \
  #         -- "$@"
  #   '';

  #   scriptArgs = "${pkgs.scooper}/bin/scooper \${LITTERBOX_DB}";
  # };

  # systemd.services.hledger-web = {
  #   environment.LEDGER_FILE = ledgerFile;

  #   restartTriggers = [ pkgs.hledger-web ];
  #   restartIfChanged = true;

  #   script = ''
  #     ${pkgs.hledger-web}/bin/hledger-web \
  #         --serve \
  #         --socket=${hledgerWebSocket} \
  #         --base-url=https://ledger.somas.is \
  #         --allow=edit
  #   '';
  #   wantedBy = [
  #     "default.target"
  #     "nginx.service"
  #   ];
  #   serviceConfig = {
  #     Restart = "always";
  #     UMask = "002"; # create socket with group readability so nginx can access it
  #     User = "somasis";
  #     Group = "somasis";
  #     RuntimeDirectory = "hledger-web";
  #   };
  # };

  # <https://wiki.nixos.org/wiki/Nginx#UNIX_socket_reverse_proxy>
  # systemd.services.nginx.serviceConfig.ProtectHome = false;

  services.nginx = {
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;

    virtualHosts = {
      # "ledger.somas.is" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   basicAuthFile = config.age.secrets.somasis-htpasswd-ledger;
      #   locations."/".proxyPass = "http://unix:${hledgerWebSocket}";
      # };

      "pounce.somas.is" = {
        useACMEHost = "pounce.somas.is";
        forceSSL = true;

        basicAuthFile = config.age.secrets.somasis-htpasswd-scooper.path;

        locations = {
          "/".root = "/var/empty";

          # "/scooper/" = {
          #   extraConfig = ''
          #     fastcgi_pass unix:${config.systemd.services.scooper.environment.SCOOPER_SOCKET};
          #     fastcgi_split_path_info (/scooper)(.*);
          #   '';
          #   fastcgiParams = {
          #     PATH_INFO = "$fastcgi_path_info";
          #   };
          # };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    6697 # pounce
    2236 # soulseek
  ];

  programs.adb.enable = true;
}

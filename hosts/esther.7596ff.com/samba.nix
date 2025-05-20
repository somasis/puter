{ config
, pkgs
, inputs
, ...
}:
{
  networking.firewall.allowedTCPPorts = [ 445 ];

  services.avahi = {
    enable = true;
    publish.enable = true;

    extraServiceFiles.smb = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name>esther</name>
          <service>
           <type>_smb._tcp</type>
           <port>445</port>
         </service>
         <service>
           <type>_device-info._tcp</type>
           <port>0</port>
           <txt-record>model=MacPro7,1</txt-record>
         </service>
         <service>
           <type>_adisk._tcp</type>
           <txt-record>sys=waMa=0,adVF=0x100</txt-record>
           <txt-record>dk0=adVN=TimeMachine,adVF=0x82</txt-record>
         </service>
      </service-group>
    '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    nsswins = true;

    settings = {
      global = {
        "inherit permissions" = "yes";
        "min protocol" = "SMB2";
        "use sendfile" = "yes";
        "vfs objects" = [
          "acl_xattr"
          "catia"
          "fruit"
          "streams_xattr"
        ];
        "fruit:advertise_fullsync" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacPro7,1";
        "fruit:nfs_aces" = "no";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";

        "usershare path" = "/var/lib/samba/usershares";
        "usershare max shares" = 100;
        "usershare allow guests" = "yes";
        "usershare owner only" = "yes";
      };

      "TimeMachine" = {
        "browseable" = "yes";
        "comment" = "Time Machine";
        "fruit:time machine" = "yes";
        "path" = "/mnt/raid/cassie/timemachine";
        "public" = "yes";
        "read only" = "no";
        "spotlight" = "yes";
        "valid users" = "cassie";
        "writable" = "yes";
      };
      "Movies" = {
        "browseable" = "yes";
        "comment" = "Movies";
        "path" = "/mnt/raid/cassie/media/movies";
        "public" = "yes";
        "read only" = "yes";
      };
      "Music" = {
        "browseable" = "yes";
        "comment" = "Music";
        "path" = "/mnt/raid/cassie/media/music/flac";
        "public" = "yes";
        "read only" = "yes";
      };
      "TV" = {
        "browseable" = "yes";
        "comment" = "TV";
        "path" = "/mnt/raid/cassie/media/tv";
        "public" = "yes";
        "read only" = "yes";
      };
      "kylie-music-lossless" = {
        "browseable" = "yes";
        "comment" = "kylie-music-lossless";
        "path" = "/mnt/raid/somasis/audio/library/lossless";
        "public" = "yes";
        "read only" = "yes";
      };
      "Kodi Screenshots" = {
        "browseable" = "yes";
        "path" = "/mnt/raid/tv/screenshots";
        "public" = "yes";
        "read only" = "yes";
      };
    };
  };

  persist.directories = [ "/var/lib/samba" ];
  cache.directories = [ "/var/cache/samba" ];
  log.directories = [ "/var/log/samba" ];

  systemd.tmpfiles.rules = [ "d /var/lib/samba/usershares 1770 root users - -" ];
}

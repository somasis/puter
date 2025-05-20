{ config
, pkgs
, ...
}:
{
  # services.nixseparatedebuginfod.enable = true;
  # cache.directories = [ "/var/cache/nixseparatedebuginfod" ];

  programs.bandwhich.enable = true;
  programs.iotop.enable = true;
}

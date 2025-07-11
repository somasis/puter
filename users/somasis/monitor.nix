{ config, ... }:
{
  programs.htop = with config.lib.htop; {
    enable = true;
    settings =
      {
        # Application settings
        color_scheme = 0;
        delay = 10;

        enable_mouse = 1;
        show_tabs_for_screens = 0;
        hide_function_bar = 1; # "Hide main function bar ... on ESC, until next input"

        # Meters - CPU meter
        cpu_count_from_one = 1;
        show_cpu_temperature = 1;
        show_cpu_frequency = 1;
        show_cpu_usage = 1;
        account_guest_in_cpu_meter = 1; # "Add guest time in CPU meter percentage"
        detailed_cpu_time = 0;
        degree_fahrenheit = 1;

        # Display options > Global options: on updates
        highlight_changes = 1;
        highlight_changes_delay_secs = 5;

        # Display options > Global options: listing
        show_program_path = 0;
        highlight_base_name = 1;
        show_merged_command = 1;
        find_comm_in_cmdline = 1;
        strip_exe_from_cmdline = 1; # Prevent names from being unreadable due to /nix/store prefix
        update_process_names = 1;
        shadow_other_users = 0;

        highlight_deleted_exe = 1; # "Highlight out-dated/removed programs / libraries"
        highlight_megabytes = 1; # "Highlight large numbers in memory counters"

        # Display options > Global options: threads
        hide_kernel_threads = 1;
        hide_userland_threads = 1;
        show_thread_names = 1;
        highlight_threads = 1; # "Display threads in a different color"

        # Display options > Tree view - tree view and sorting
        tree_view = 1;
        tree_view_always_by_pid = 0; # Don't default to sorting tree view by PID
        tree_sort_direction = 1; # Sort lowest to highest even in tree view
        tree_sort_key = 0;
        sort_direction = 0; # Sort lowest to highest
        sort_key = fields.PERCENT_CPU; # Sort by PID

        fields = with fields; [
          PID
          ELAPSED
          STATE
          NICE
          PRIORITY
          IO_PRIORITY
          # SCHEDULERPOLICY # TODO needs to be in home-manager

          PERCENT_CPU
          # GPU_PERCENT # TODO needs to be in home-manager
          PERCENT_MEM
          # M_PRIV # TODO needs to be in home-manager
          # M_SWAP # TODO needs to be in home-manager
          IO_RATE

          USER
          COMM
        ];

        header_layout = "two_50_50";
        header_margin = 1;
      }
      // leftMeters [
        (bar "CPU")
        (bar "AllCPUs4")
        (bar "Memory")
        (bar "Zram")
        (text "Tasks")
        (text "LoadAverage")
      ]
      // rightMeters [
        (text "Hostname")
        (text "System")
        (text "Uptime")
        (text "Systemd")
        (text "SystemdUser")
        (text "DiskIO")
        (text "ZFSCARC")
        (text "NetworkIO")
      ];
  };

  # Silence warning about being unable to write to configuration file.
  # Use programs.bash instead of home.shellAliases because of the `2>/dev/null` usage.
  programs.bash.shellAliases = {
    htop = "2>/dev/null htop";
    h = ''htop -u "$USER"'';
  };

  services.sxhkd.keybindings."super + alt + Delete" = "kitty --title htop --class htop htop";
}

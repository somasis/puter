{ lib
, signal-desktop
, librsvg
, papirus-icon-theme
, css ? ""
, iconThemePkg ? papirus-icon-theme
, iconThemeName ? "Papirus-Dark"
,
}:
signal-desktop.overrideAttrs (oldAttrs: rec {
  nativeBuildInputs =
    (oldAttrs.nativeBuildInputs or [ ])
    ++ lib.optional (iconThemePkg != null) librsvg;

  buildInputs = (oldAttrs.buildInputs or [ ]) ++ lib.optional (iconThemePkg != null) iconThemePkg;

  patchPhase =
    (oldAttrs.patchPhase or "")
    + lib.optionalString (iconThemePkg != null) ''
      ${lib.toShellVar "icon_package" iconThemePkg}
      ${lib.toShellVar "icon_name" iconThemeName}

      # Patch CSS to use accent color in place of Signal brand color
      substituteInPlace asar-contents/stylesheets/manifest.css \
          --replace-fail '#2c6bed' 'var(--somasis-accent-text-color)'

      echo "patching tray icons" >&2

      source_target_icon_pairs=(
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-tray.svg":"asar-contents/images/tray-icons/base/signal-tray-icon-@@icon_size@@x@@icon_size@@-base.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-1.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-1.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-2.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-2.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-3.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-3.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-4.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-4.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-5.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-5.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-6.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-6.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-7.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-7.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-8.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-8.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-9.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-9.png"
          "$icon_package/share/icons/$icon_name/@@icon_size@@x@@icon_size@@/@@icon_category@@/signal-unread-10.svg":"asar-contents/images/tray-icons/alert/signal-tray-icon-@@icon_size@@x@@icon_size@@-alert-9+.png"
      )

      target_icon_sizes=( 16 32 48 256 )
      source_icon_sizes=( 256 64 48 32 24 22 16)
      patched=
      for target_icon_size in "''${target_icon_sizes[@]}"; do
          if [[ "$patched" == false ]]; then
              echo "error: failed patching ''${target_icon@Q}" >&2
              exit 1
          fi

          echo "target icon size: $target_icon_size" >&2
          for icon_pair in "''${source_target_icon_pairs[@]}"; do
              source_icon="''${icon_pair%:*}"
              target_icon="''${icon_pair#*:}"

              source_icon=$(
                  source_icon_orig="$source_icon"
                  for source_icon_size in "$target_icon_size" "''${source_icon_sizes[@]}"; do
                      source_icon_candidate="''${source_icon_orig//@@icon_size@@/$source_icon_size}"

                      for source_icon_category in panel status; do
                          source_icon_candidate="''${source_icon_candidate//@@icon_category@@/$source_icon_category}"

                          if [[ -e "$source_icon_candidate" ]]; then
                              echo "$source_icon_candidate"
                              return 0
                          fi
                      done
                  done
                  echo "error: source icon could not be found; last tried $source_icon_candidate" >&2
                  exit 1
              )

              target_icon="''${target_icon//@@icon_size@@/$target_icon_size}"
              if ! [[ -e "$target_icon" ]]; then
                  echo "error: target icon ''${target_icon} does not exist" >&2
                  exit 1
              fi

              echo "  replacing $target_icon with $source_icon" >&2

              if [[ "$patched" == false ]]; then
                  echo "error: failed patching ''${target_icon@Q}" >&2
                  exit 1
              fi

              patched=false
              if rsvg-convert --width $(( target_icon_size * 2 )) --height $(( target_icon_size * 2 )) --keep-aspect-ratio --output "$target_icon" "$source_icon"; then
                  patched=true
              fi
          done

      done
    ''
    + lib.optionalString (css != "") ''
      # Inject custom CSS
      cat - ${css} >>asar-contents/stylesheets/manifest.css <<'EOF'
      /* Added by Home Manager */
      EOF
    '';
})

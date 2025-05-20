{
  home.packages = [ pkgs.xorg.xterm ];

  services.sxhkd.keybindings."super + b" = "xterm";

  xresources.properties = {
    # xterm(1) settings
    "xterm*termName" = "xterm-256color";
    "xterm*utf8" = true;

    ## Input settings

    ### Send as Alt as expected in other terminals
    "xterm*metaSendsEscape" = true;

    ### Send ^? on backspace instead of ^H
    "xterm*backarrowKey" = false;
    "xterm.ttyModes" = "erase ^?";

    ## Behavior settings

    ### Translations (keybinds, mouse behavior)
    "xterm.vt100.translations" =
      "#override \\n\\
          Ctrl <Key>minus: smaller-vt-font()\\n\\
          Ctrl <Key>plus: larger-vt-font()\\n\\
          Ctrl <Key>0: set-vt-font(d)\\n\\
          Ctrl Shift <Key>C: copy-selection(CLIPBOARD)\\n\\
          Ctrl Shift <Key>V: insert-selection(CLIPBOARD)\\n\\
          Ctrl <Btn1Up>: exec-formatted(\"printf '%%s\\n' %s | xterm-open\", SELECT)\\n\\
          Ctrl Shift <Key>O: print-everything(noAttrs, noNewLine)";

    "xterm*printerCommand" = "xterm-open";

    ### Mouse selection behavior

    "xterm*on2Clicks" = "word";
    "xterm*on3Clicks" = "line";
    "xterm*on4Clicks" =
      "regex ([[:alpha:]]+://)?([[:alnum:]!#+,./=?@_~-]|(%[[:xdigit:]][[:xdigit:]]))+";

    #### Understand URLs as words <https://pbrisbin.com/posts/selecting_urls_via_keyboard_in_xterm/>
    "xterm*charClass" = [
      "33:48"
      "37-38:48"
      "45-47:48"
      "64:48"
      "126:48"
      "61:48"
      "63:48"
      "43:48"
      "35:48"
    ];

    ### Clipboard behavior
    "xterm*selectToClipboard" = true; # Use CLIPBOARD, not PRIMARY

    ### Disable popup menus entirely
    "xterm*omitTranslation" = "popup-menu";

    ### Translate terminal bells as window urgency
    "xterm*bellIsUrgent" = true;

    ## Graphical settings
    "xterm*renderFont" = true;

    "xterm*pointerShape" = "left_ptr";

    "xterm*fullscreen" = "never";

    ### Fix lag with things that shift the entire terminal contents
    "xterm*fastScroll" = true;

    ### SIXEL support
    "xterm*decGraphicsID" = "vt340";
    "xterm*numColorRegisters" = 256;
    "xterm*sixelScrolling" = true;

    "xterm*internalBorder" = 0;
    "xterm*showMissingGlyphs" = true;

    ### Scrolling settings
    "xterm*scrollBar" = false;
    "xterm*scrollTtyOutput" = false;
    "xterm*scrollKey" = true;

    ### Cursor (as in, the prompt cursor) display settings
    "xterm*cursorUnderLine" = false;
    "xterm*cursorBlink" = true;
    "xterm*cursorOnTime" = 500;
    "xterm*cursorOffTime" = 500;

    ### Do not display boldness with a color
    "xterm*boldColors" = false;
  };
}

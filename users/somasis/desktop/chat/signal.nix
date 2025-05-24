{ config
, pkgs
, lib
, osConfig
, ...
}:
let
  inherit (lib)
    mapAttrs'
    nameValuePair
    ;

  inherit (config.lib.somasis)
    camelCaseToKebabCase
    ;

  inherit (config.lib.somasis) colors;
  c = config.theme.colors;

  # signal = pkgs.signal-desktop-patched.override {
  #   iconThemeName = config.gtk.iconTheme.name;
  #   iconThemePkg = config.gtk.iconTheme.package;

  #   # Use `signal-desktop --enable-dev-tools` to enable the web inspector.
  #   css = pkgs.writeCss "signal.css" { } ''
  #     :root {
  #       --somasis-accent-color-rgb: ${
  #         lib.pipe c.accent [
  #           colors.rgb
  #           (lib.replaceStrings [ "rgb(" ")" ] [ "" "" ])
  #         ]
  #       };
  #       --somasis-accent-color: ${c.accent};
  #       --somasis-accent-text-color: ${c.accentText};
  #       --somasis-dim-accent-color: ${c.dimAccent};
  #       --somasis-dim-accent-text-color: ${c.dimAccentText};
  #       --somasis-menu-background-color: ${c.menuBackground};
  #       --somasis-menu-foreground-color: ${c.menuForeground};
  #       --somasis-header-background-color: ${c.headerBackground};
  #       --somasis-header-foreground-color: ${c.headerForeground};
  #       --somasis-dark-window-background-color: ${c.darkWindowBackground};
  #       --somasis-dark-window-foreground-color: ${c.darkWindowForeground};
  #       --somasis-light-window-background-color: ${c.lightWindowBackground};
  #       --somasis-light-window-foreground-color: ${c.lightWindowForeground};
  #       --somasis-button-background-color: ${c.buttonBackground};
  #       --somasis-button-foreground-color: ${c.buttonForeground};
  #       --tooltip-background-color: ${c.tooltipBackground};
  #       --tooltip-text-color: ${c.tooltipForeground};
  #     }

  #     .module-tooltip, .module-tooltip--dark-theme {
  #       background-color: ${c.tooltipBackground};
  #       color: ${c.tooltipForeground};
  #     }

  #     @media (prefers-color-scheme: dark) {
  #       :root {
  #         --somasis-window-background-color: var(--somasis-dark-window-background-color);
  #         --somasis-window-foreground-color: var(--somasis-dark-window-foreground-color);
  #       }
  #     }
  #     @media (prefers-color-scheme: light) {
  #       :root {
  #         --somasis-window-background-color: var(--somasis-light-window-background-color);
  #         --somasis-window-foreground-color: var(--somasis-light-window-foreground-color);
  #       }
  #     }

  #     body {
  #       font-family: sans-serif;
  #       background-color: var(--somasis-window-background-color);
  #       foreground-color: var(--somasis-window-foreground-color);
  #       color: var(--somasis-window-foreground-color);
  #     }

  #     .module-SearchInput__input,
  #     .module-composition-input__input,
  #     .module-message__container
  #     {
  #       border-radius: 10px;
  #     }

  #     .NavTabs__ItemUnreadBadge {
  #       color: var(--somasis-accent-color);
  #       background-color: var(--somasis-accent-text-color);
  #       font-weight: 900 !important;
  #     }

  #     .module-conversation-list__item--contact-or-conversation--is-selected {
  #       background-color: var(--somasis-accent-color);
  #     }

  #     .module-conversation-list__item--contact-or-conversation--is-selected .module-conversation-list__item--contact-or-conversation__content__header span,
  #     .module-conversation-list__item--contact-or-conversation--is-selected .module-conversation-list__item--contact-or-conversation__content__message__text,
  #     .module-conversation-list__item--contact-or-conversation--is-selected .module-conversation-list__item--contact-or-conversation__content__header__date
  #     {
  #       color: var(--somasis-accent-text-color);
  #     }

  #     .module-composition-input__input {
  #       background-color: #fff;
  #       color: #000;
  #       border-radius: .125;
  #     }

  #     .NavSidebar {
  #       border-width: 0;
  #     }

  #     .NavTabs__Item
  #     {
  #       padding: 0 .75rem;
  #     }

  #     button.NavTabs__Item.NavTabs__Toggle {
  #       padding: .75rem 0;
  #     }

  #     .NavSidebar__Header button.NavTabs__Item.NavTabs__Toggle{
  #       padding: .5rem 0 !important;
  #     }

  #     .NavSidebar__Header,
  #     .module-ConversationHeader {
  #       height: 3.25rem;
  #       background-color: var(--somasis-header-background-color);
  #       color: var(--somasis-header-foreground-color);
  #     }

  #     .NavSidebar__Header {
  #       height: 3.25rem;
  #       padding-top: 4px;
  #     }

  #     .module-ConversationHeader button:before,
  #     .module-ConversationHeader .module-in-contacts-icon__icon
  #     {
  #       background-color: var(--somasis-header-foreground-color);
  #     }

  #     .NavTabs {
  #       background-color: var(--somasis-header-background-color);
  #     }

  #     .NavTabs__ItemIcon {
  #       background-color: var(--somasis-header-foreground-color);
  #     }

  #     .react-contextmenu-item.react-contextmenu-item--active,
  #     .react-contextmenu-item.react-contextmenu-item--selected,
  #     .NavTabs__Item:active .NavTabs__ItemButton,
  #     .NavTabs__Item[aria-selected=true] .NavTabs__ItemButton {
  #       border-color: var(--somasis-accent-color);
  #       color: var(--somasis-accent-text-color);
  #       background-color: var(--somasis-accent-color) !important;
  #     }

  #     .NavTabs__Item:active [role='presentation'],
  #     .NavTabs__Item[aria-selected=true] [role='presentation'],
  #     .NavTabs__ItemIcon--Menu:active
  #     {
  #       background-color: #fff;
  #     }

  #     .ContextMenu__popper {
  #       background-color: var(--somasis-menu-background-color);
  #       color: var(--somasis-menu-foreground-color);
  #       box-shadow: 0px 0px 4px rgba(0,0,0,.25);
  #     }

  #     .react-contextmenu {
  #       background-color: var(--somasis-menu-background-color);
  #       color: var(--somasis-menu-foreground-color);
  #     }

  #     .module-SearchInput__input {
  #       border-radius: 4px;
  #       background-color: #fff;
  #     }

  #     .NavSidebarSearchHeader {
  #       margin: 1rem;
  #       margin-bottom: 0px;
  #     }

  #     button.NavSidebar__ActionButton span {
  #       background-color: var(--somasis-accent-text-color);
  #     }

  #     .NavTabs__Toggle .NavTabs__ItemButton {
  #       margin-inline: 0;
  #       margin-left: 1rem;
  #     }

  #     .NavTabs {
  #       width: 4rem;
  #     }

  #     .ConversationView__composition-area,
  #     .CompositionArea__toggle-large {
  #         background-color: #ececec;
  #     }

  #     .module-ConversationHeader__button:not(:disabled):hover
  #     {
  #         background-color: #fafafa;
  #     }

  #     .module-ConversationHeader__button:not(:disabled):hover::before {
  #         background-color: var(--somasis-accent-color);
  #     }


  #     .react-contextmenu-item:not(:disabled):hover::before,
  #     .react-contextmenu-item:not(:disabled):hover::after,
  #     .react-contextmenu-item:not(:disabled):active::before,
  #     .react-contextmenu-item:not(:disabled):active::after,
  #     .react-contextmenu-item:not(:disabled):hover > div::before,
  #     .react-contextmenu-item:not(:disabled):active > div::before {
  #         background-color: #fff !important;
  #     }

  #     button.module-Button:not(:disabled),
  #     button.module-Button:not(:disabled):hover {
  #         background-color: var(--somasis-button-background-color) !important;
  #         color: var(--somasis-button-foreground-color) !important;
  #     }

  #     button.module-Button:not(:disabled):active {
  #         background-color: var(--somasis-accent-color) !important;
  #         color: var(--somasis-accent-text-color) !important;
  #     }
  #     .module-SearchInput__input,
  #     .module-composition-input__input {
  #         border-radius: 5px;
  #     }

  #     .module-composition-input__input:focus-within,
  #     input:focus-within,
  #     .Input__container:focus-within {
  #         border-color: var(--somasis-accent-color);
  #     }

  #     .module-message__container {
  #         border-radius: 10px;
  #     }

  #     .module-tooltip, .module-tooltip--dark-theme {
  #         background-color: #f5f5b5 !important;
  #         color: #000 !important;
  #     }

  #     .CompositionArea__button-cell button:not(:disabled) {
  #         border-radius: 5px;
  #     }

  #     .CompositionArea__button-cell button:not(:disabled):hover {
  #         background-color: var(--somasis-button-background-color) !important;
  #     }

  #     .CompositionArea__button-cell button:not(:disabled):active,
  #     .CompositionArea__button-cell button:not(:disabled):focus,
  #     [class*='__button-cell'] button[class*='__button--active'],
  #     [class*='__button-cell'] button[class*='__button--active']:hover {
  #         background-color: var(--somasis-accent-color) !important;
  #     }

  #     .CompositionArea__button-cell button:not(:disabled):active::before,
  #     .CompositionArea__button-cell button:not(:disabled):focus::before,
  #     .CompositionArea__button-cell button:not(:disabled):active::after,
  #     .CompositionArea__button-cell button:not(:disabled):focus::after,
  #     [class*='__button-cell'] button[class*='__button--active']::before,
  #     [class*='__button-cell'] button[class*='__button--active']::after,
  #     [class*='__button-cell'] button[class*='__button--active']:hover::before,
  #     [class*='__button-cell'] button[class*='__button--active']:hover::after
  #     {
  #         background-color: var(--somasis-accent-text-color) !important;
  #     }

  #     .WhatsNew {
  #       color: var(--somasis-accent-color);
  #     }

  #     .module-Button--primary:is(:disabled, [aria-disabled=true]) {
  #       background-color: var(--somasis-dim-accent-color);
  #       color: var(--somasis-dim-accent-text-color);
  #       opacity: .5;
  #     }

  #     [class*='module-conversation-list__item--'][class*='__status-icon'] {
  #       background-color: var(--somasis-accent-text-color);
  #     }
  #   '';
  # };
in
{
  home.packages = with pkgs; [ signal-desktop ];

  persist.directories = [ (config.lib.somasis.xdgConfigDir "Signal") ];

  xdg.configFile."Signal/ephemeral.json".text = lib.generators.toJSON { } (
    mapAttrs' (n: v: nameValuePair (camelCaseToKebabCase n) v) {
      systemTraySetting = "MinimizeToAndStartInSystemTray";
      shownTrayNotice = true;

      themeSetting = "system";

      window = mapAttrs' (n: v: nameValuePair (camelCaseToKebabCase n) v) {
        autoHideMenuBar = true;
      };

      spellCheck = true;
    }
  );
}

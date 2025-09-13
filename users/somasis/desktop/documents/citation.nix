{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (config.lib.somasis) flakeModifiedDateToVersion;

  qutebrowser-zotero = pkgs.callPackage (
    {
      lib,
      # fetchFromGitHub,
      python3Packages,
    }:
    python3Packages.buildPythonApplication rec {
      pname = "qutebrowser-zotero";
      # version = "unstable-2019-06-15";
      version = flakeModifiedDateToVersion inputs.qutebrowser-zotero;

      format = "other";

      # src = fetchFromGitHub {
      #   owner = "parchd-1";
      #   repo = "qutebrowser-zotero";
      #   rev = "54706b43433c3ea8da6b7b410d67528da9779657";
      #   hash = "sha256-Jv5qrpWSMrfGr6gV8PxELCOfZ0PyGBPO+nBt2czYuu4=";
      # };
      src = inputs.qutebrowser-zotero;

      propagatedBuildInputs = with python3Packages; [ requests ];

      installPhase = ''
        install -m0755 -D $src/qute-zotero $out/bin/qute-zotero
      '';

      meta = with lib; {
        description = "Connect qutebrowser to a running Zotero instance";
        homepage = "https://github.com/parchd-1/qutebrowser-zotero";
        maintainers = with maintainers; [ somasis ];
        license = licenses.gpl3;
        mainProgram = "qute-zotero";
      };
    }
  ) { };
in
{
  programs.zotero = {
    enable = true;

    profiles.default = {
      settings =
        let
          # Chicago Manual of Style [latest] edition (note)
          style = "http://www.zotero.org/styles/chicago-note-bibliography";
          locale = "en-US";
        in
        rec {
          # See <https://www.zotero.org/support/preferences/hidden_preferences> also.
          "general.smoothScroll" = false;
          "intl.accept_language" = "en-US, en";

          # Use the flake-provided versions of translators and styles.
          # "extensions.zotero.automaticScraperUpdates" = false;
          "extensions.zotero.automaticScraperUpdates" = true;

          # Use Appalachian State University's OpenURL resolver
          "extensions.zotero.findPDFs.resolvers" = [
            {
              "name" = "Sci-Hub";
              "method" = "GET";
              "url" = "https://sci-hub.ru/{doi}";
              "mode" = "html";
              "selector" = "#pdf";
              "attribute" = "src";
              "automatic" = true;
            }
            {
              "name" = "Google Scholar";
              "method" = "GET";
              "url" = "{z:openURL}https://scholar.google.com/scholar?q=doi%3A{doi}";
              "mode" = "html";
              "selector" = ".gs_or_ggsm a:first-child";
              "attribute" = "href";
              "automatic" = true;
            }
          ];

          # Sort settings
          "extensions.zotero.sortAttachmentsChronologically" = true;
          "extensions.zotero.sortNotesChronologically" = true;

          # Item adding settings
          "extensions.zotero.automaticSnapshots" = true; # Take snapshots of webpages when items are made from them
          "extensions.zotero.translators.RIS.import.ignoreUnknown" = false; # Don't discard unknown RIS tags when importing
          "extensions.zotero.translators.attachSupplementary" = true; # "Translators should attempt to attach supplementary data when importing items"

          # Citation settings
          "extensions.zotero.export.lastStyle" = style;
          "extensions.zotero.export.quickCopy.locale" = locale;
          "extensions.zotero.export.quickCopy.setting" = "bibliography=${style}";
          "extensions.zotero.export.citePaperJournalArticleURL" = false;

          # Feed options
          "extensions.zotero.feeds.defaultTTL" = 24 * 7; # Refresh feeds every week
          "extensions.zotero.feeds.defaultCleanupReadAfter" = 60; # Clean up read feed items after 60 days
          "extensions.zotero.feeds.defaultCleanupUnreadAfter" = 90; # Clean up unread feed items after 90 days

          # Attachment settings
          "extensions.zotero.useDataDir" = true;
          "extensions.zotero.dataDir" = "${config.xdg.dataHome}/zotero";

          # Reading settings
          "extensions.zotero.tabs.title.reader" = "filename"; # Show filename in tab title

          # Sync settings
          "extensions.zotero.sync.protocol" = "webdav";
          "extensions.zotero.sync.storage.url" = "files.box.somas.is";
          "extensions.zotero.sync.storage.username" = "somasis";

          # "extensions.zotero.attachmentRenameFormatString" = "{%c - }%t{100}{ (%y)}"; # Set the file name format used by Zotero's internal stuff

          "extensions.zotero.autoRenameFiles.fileTypes" = lib.concatStringsSep "," [
            "application/pdf"
            "application/epub+zip"
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "application/vnd.oasis.opendocument.text"
          ];

          # Zotero OCR
          "extensions.zotero.zoteroocr.pdftoppmPath" = "${pkgs.poppler_utils}/bin/pdftoppm";
          "extensions.zotero.zoteroocr.ocrPath" = "${pkgs.tesseract}/bin/tesseract";
          "extensions.zotero.zoteroocr.language" = "eng";

          "extensions.zotero.zoteroocr.outputPDF" = true; # Output options > "Save output as a PDF with text layer"
          "extensions.zotero.zoteroocr.overwritePDF" = true; # Output options > "Save output as a PDF with text layer" > "Overwrite the initial PDF with the output"

          "extensions.zotero.zoteroocr.outputHocr" = false; # Output options > "Save output as a HTML/hocr file(s)"
          "extensions.zotero.zoteroocr.outputNote" = false; # Output options > "Save output as a note"
          "extensions.zotero.zoteroocr.outputPNG" = false; # Output options > "Save the intermediate PNGs as well in the folder"

          "ui.use_activity_cursor" = true;

          # LibreOffice extension settings
          "extensions.zotero.integration.useClassicAddCitationDialog" = true;
          "extensions.zoteroOpenOfficeIntegration.installed" = true;
          "extensions.zoteroOpenOfficeIntegration.skipInstallation" = true;

          "extensions.zotero.reader.ebookFontFamily" = "serif";

          # "extensions.zotero.openReaderInNewWindow" = true;

          # ouch
          "extensions.zotero.attachmentRenameTemplate" = ''
            {{ if {{ creators }} != "" }}{{ if {{ creators max="1" name-part-separator=", " }} == {{ creators max="1" name="family-given" }}, }}{{ creators max="2" name="family-given" join=", " suffix=" - " }}{{ else }}{{ if {{ creators max="1" }} != {{ creators max="2" }} }}{{ creators max="1" name="family-given" name-part-separator=", " join=", " suffix=" et al. - " }}{{ else }}{{ creators max="2" name="family-given" name-part-separator=", " join=", " suffix=" - " }}{{ endif }}{{ endif }}{{ else }}{{ creators max="1" name="family-given" name-part-separator=", " }}{{ endif }}{{ if shortTitle != "" }}{{ shortTitle }}{{ else }}{{ if {{ title truncate="80" }} == {{ title }} }}{{ title }}{{ else }}{{ title truncate="80" suffix="..." }}{{ endif }}{{ endif }}{{ if itemType == "book" }} ({{ year }}{{ publisher truncate="80" prefix=", " }}){{ elseif itemType == "bookSection" }} ({{ year }}{{ bookTitle prefix=", " truncate="80" }}){{ elseif itemType == "blogpost" }} ({{ if year != "" }}{{ year }}{{ blogTitle prefix=", " }}{{ else }}{{ blogTitle }}{{ endif }}){{ elseif itemType == "webpage" }} ({{ year }}{{ websiteTitle prefix=", " }}){{ elseif itemType == "newspaperArticle" }} ({{ year }}{{ publicationTitle truncate="80" prefix=", " }}{{ section truncate="80" prefix=", " }}){{ elseif itemType == "presentation" }} ({{ year }}{{ meetingName truncate="80" prefix=", " }}){{ elseif publicationTitle != "" }} ({{ year }}{{ publicationTitle truncate="80" prefix=", " }}{{ if volume != year }}{{ volume prefix=" "  }}{{ endif }}{{ issue prefix=", no. " }}){{ elseif year != "" }} ({{ year }}){{ endif }}
          '';
          "extensions.zotero.autoRenameFiles.linked" = true;

          # <https://github.com/MuiseDestiny/zotero-attanger>
          "extensions.zotero.zoteroattanger.sourceDir" = config.xdg.userDirs.download;
          "extensions.zotero.zoteroattanger.readPDFtitle" = "always";
          "extensions.zotero.zoteroattanger.attachType" = "importing";
          "extensions.zotero.zoteroattanger.destDir" = "${config.xdg.userDirs.documents}/articles";
          "extensions.zotero.zoteroattanger.autoRemoveEmptyFolder" = true;
          "extensions.zotero.zoteroattanger.fileTypes" = lib.concatStringsSep "," [
            "pdf"
            "epub"
            "docx"
            "odt"
          ];

          # Enable userChrome
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

      userChrome = ''
        * {
            /* Disable animations */
            transition: none !important;
            transition-duration: 0 !important;

            /* Square everything */
            border-radius: 0 !important;

            /* No shadows */
            box-shadow: none !important;
        }

        :root {
            --tab-min-height: 44px;
        }

        :root:not([legacytoolbar="true"]) {
            --tab-min-height: 36px;
        }

        /* Use Arc's style for toolbars */
        #titlebar {
            background: ${config.theme.colors.toolbarBackground} !important; /* config.theme.colors.background */
            color: ${config.theme.colors.toolbarForeground} !important; /* config.theme.colors.foreground */
        }
      '';
    };
  };

  persist.directories = [
    {
      method = "bindfs";
      directory = ".zotero";
    }

    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "zotero";
    }
  ];

  programs.qutebrowser = {
    aliases.zotero = "spawn -u ${qutebrowser-zotero}/bin/qute-zotero";
    aliases.Zotero = "hint links userscript ${qutebrowser-zotero}/bin/qute-zotero";
    keyBindings.normal = {
      "zpz" = "zotero";
      "zpZ" = "Zotero";
    };
  };
}

// ==UserScript==
// @name         Quirks
// @author       Kylie McClain <kylie@somas.is>
// @include      http://*
// @include      https://*
// @grant        GM_addStyle
// ==/UserScript==

(function () {
  "use strict";

  /* quickest reference:
   * - URLPattern argument values are not regex, they're actually kinda
   *   like globs, so use `*` not `.*`.
   * - groups: `{www.}?example.org` matches example.org and www.example.org,
   *   and `{*.}?example.org` matches example.org and any subdomain of it.
   */
  // <https://urlpattern.spec.whatwg.org/>
  // <https://github.com/whatwg/urlpattern/blob/main/mdn-drafts/QUICK-REFERENCE.md>
  // <https://developer.mozilla.org/en-US/docs/Web/API/URLPattern/URLPattern>
  function matchURL(URLPatternArgs) {
    return new URLPattern(URLPatternArgs).test(document.location);
  }

  function matchAnyURL(URLPatternArgsList) {
    if (typeof URLPatternArgsList != "list") {
      throw new Error("argument must be list");
    }

    var matched = false;

    for (const URLPatternArgs of URLPatternArgsList) {
      if (matchURL(URLPatternArgs)) matched = true;
    }

    return matched;
  }

  var style = "";

  /* Disable all element animations, unless they're a list of exceptions;
   * some stupid sites never hide their animation elements for some reason,
   * which causes issues if you disable animations entirely... */
  if (
    !(
      matchURL({ hostname: "{www.}?paypal.com" }) ||
      matchURL({ hostname: "{*.}?nytimes.com", pathname: "*/games/*" })
    )
  )
    style += `
          *:not(
            [id*="loading" i],
            [id*="spinner" i],
            [id*="progress" i],
            [class*="loading" i],
            [class*="spinner" i],
            [class*="progress" i],
            [role*="loading" i],
            [role*="spinner" i],
            [role*="presentation" i],
            [role*="progress" i],
            :has(
              [id*="loading" i],
              [id*="spinner" i],
              [id*="progress" i],
              [class*="loading" i],
              [class*="spinner" i],
              [class*="progress" i],
              [role*="loading" i],
              [role*="spinner" i],
              [role*="presentation" i],
              [role*="progress" i]
            )
          ) {
            animation-duration: 0s !important;
            transition-duration: 0s !important;
          }
        `;

  /* github.com: redirect .patch URLs to the actual pull request */
  if (matchURL({ hostname: "github.com", pathname: "*/pull/*.patch" })) {
    const parts = document.location.pathname.match("/([^/]+/[^/]+)/pull/([0-9]+)\.patch");
    document.location = `https://github.com/${parts[1]}/pull/${parts[2]}`;
  }

  /* nytimes.com: Hide Wordle ad container */
  if (matchURL({ hostname: "{www.}?nytimes.com", pathname: "*/games/wordle/*" }))
    style += `
      [class*="Ad-module_adContainer"] {
          display: none !important;
        }
      `;

  // if (document.location.hostname == "bsky.app")
  //     style += `
  //         body {
  //             overflow-y: hidden !important;
  //         }

  //         .r-1owuwv7 {
  //             scrollbar-gutter: initial !important;
  //         }
  //     `;

  /* Blur Reddit posts that are tagged as NSFW. */
  if (matchURL({ hostname: "{*.}?reddit.com" }))
    style += `
        div.sitetable > div .thing[data-nsfw="true"] .thumbnail:not(.default, .self)
        {
          filter: blur(4px) grayscale(1);
        }

        div.sitetable > div .thing[data-nsfw="true"] .entry
        {
          filter: blur(4px);
          opacity: .35;
        }

        div.sitetable > div .thing[data-nsfw="true"]:hover .entry,
        div.sitetable > div .thing[data-nsfw="true"]:hover .thumbnail:not(.default, .self),
        div.sitetable > div .thing[data-nsfw="true"]:focus .entry,
        div.sitetable > div .thing[data-nsfw="true"]:focus .thumbnail:not(.default, .self),
        div.sitetable > div .thing[data-nsfw="true"]:active .entry
        div.sitetable > div .thing[data-nsfw="true"]:active .thumbnail:not(.default, .self),
        div.sitetable > div .thing[data-nsfw="true"]:has(div.expando:empty),

        /* don't blur NSFW when entire page is NSFW posts */
        div.sitetable > div:not(:has(.thing[data-nsfw="false"])) .thing[data-nsfw="true"] .thumbnail,
        div.sitetable > div:not(:has(.thing[data-nsfw="false"])) .thing[data-nsfw="true"] .entry
        {
          filter: none !important;
          opacity: 1 !important;
        }
      `;

  if (style != "") GM_addStyle(style);
})();

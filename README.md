# puter

Here's how I use the computer.

This repository is my NixOS and home-manager configurations, and
[scripts](#bin).

## Hacking

Before creating any commits,
ensure that you have [`direnv`] available and loaded in your shell.
Then, run

    $ direnv allow

which will give permission to load the development shell,
which includes Git hooks, and tools like `npins`, `nix-update`,
and a `nixos-rebuild` wrapper I use (simply named `nixos`).
See [`shell.nix`][shell.nix] for more details.

Alternatively, you could just run `nix-shell .` or `nix develop`.

I don't use flakes.
If you're interested in how I structure things without flakes,
check out this [blog post].
That said, there is compatibility infrastructure provided
so that this can be used as a flake if you need to,
with the caveat that you can't override inputs.
Run `nix flake show` if you don't believe me! :)

[shell.nix]: ./shell.nix
[`direnv`]: https://github.com/direnv/direnv
[blog post]: https://www.somas.is/note-organizing-nix-configuration-without-flakes.html

### Updating sources (i.e., the NixOS version used to build system)

    # update *and* commit the changes (command provided by shell.nix):
    $ npins-update-commit
    # or just update
    $ npins update

Make sure to ensure things work and build after doing so and before
pushing a lock update, if you can.

## `bin`

Here's a little exposition;
I have a few scripts in here that I think are worth talking about.

### `beets-import-to-library`

Many of the tools I've written recently have been in service of making
Beets, the command-line music organizer, nicer to use in a non-terminal
environment.

The idea here is to provide a semi-interactive script for importing
albums into the Beets library, allowing the user to break out into more
manual usage of `beet import <album>...​` when necessary.

I recently started using KDE Plasma as my main desktop environment after
years of using a `bspwm` based setup,
so I've sought to integrate it into some typical use cases.
Consequentially, there's a KIO service menu for this tool located at
[`./share/kio/servicemenus/beets.desktop`][beets.desktop].
It provides a nice menu item, and that's the primary way I interact with it.

Here's a thousand words:

[The menu item][beets.desktop], as shown in Dolphin:

![A popup menu created by a right-click action on a directory named
"Phish - Slip Stitch and Pass (1997)"][img-menuitem]

Notification of import starting soon:

![A desktop notification as produced by KDE Plasma][img-importing]

Notification of successful import:

![A desktop notification as produced by KDE Plasma][img-imported]

[beets.desktop]: ./share/kio/servicemenus/beets.desktop
[img-menuitem]: ./img/beets-import-to-library%20(menu%20item).png
[img-importing]: ./img/beets-import-to-library%20(importing).png
[img-imported]: ./img/beets-import-to-library%20(imported).png

#### `beet-hook-diff-{pluginload,cli_exit}`

These two scripts work to provide a hook for Beets
that shows a diff of all the changes that happened to its `library.db`
during its run.

They both require that `sqlite3` be present in the `$PATH`.
The `diff` is calculated using the output of `sqlite3`'s `.dump` command.

To use these hooks properly, both need to be declared in Beets' config:

beets `config.yaml` excerpt:

```yaml
plugins:
  - hook

hook:
  hooks:
    - event: pluginload
      command: beet-hook-diff-pluginload
    - event: cli_exit
      command: beet-hook-diff-cli_exit
```

Pitfalls

The `pluginload` hook merely writes the "before"-state of the database,
and the `cli_exit` one writes the "after"-state.
Notably, this means that the diff is liable to be inaccurate
and show too many changes if you have multiple instances of `beet`
modifying the database at the same time.
Future plans include fixing this
by making the hooks run closer to the database opens and writes,
such as running `pluginload` at `library_opened` instead.
Plus, instead of gathering changes,
the `cli_exit` hook could be ran at `database_change`,
and then the change diffs could be written incrementally,
being more accurate to changes done by the invoking instance of `beet`.
If we keep using `.dump` though,
that would bring along all the impediments that incurs
(slowing down `beet` by dumping already calculated database values,
and potentially causing lots of churn).

### phish-cli

- [`beet-import-phish`]
- [`phish-download-show`]
- [`phish-list-shows`]
- [`phish-show-notes`]
- [`phishin-auth-token`]
- [`phishin-like-show`]
- [`phishin-like-track`]

So here's the idea.
Let's say you're a fan of the jam band [Phish];
it could happen to you!
In the last year or so after leaving college, I got really into Phish,
and I wanted to write something that would let me listen to shows on
[Phish.in] without using the website.
I wrote some initial versions that used `mpv` to play them,
mostly fumbling around with trying to get `mpv` to do gapless playback
of the MP3 files being streamed directly from Phish.in.
Eventually, it seemed that I would need to reencode the MP3 files in
order to get it to play gaplessly,
and if I need to download them just to get gapless playback,
then I might as well automate the process
of downloading shows and importing them into in my music library properly,
and simply _play them with my music player_ instead of using `mpv`.
Naturally, it turned into a lot of effort because I was having fun with
figuring out the most ergonomic design for the tools.

A typical session:

    ~ ∴ phish-list-shows -d 1998 | shuf -n 1
    1998-11-04
    ~ ∴ phish-show-notes 1998-11-04
    Phish
    1998-11-04
    1998 Fall Tour
    McNichols Arena, Denver, CO, USA

    Set 1: Buried Alive > Character Zero, Guyute > Gin > Ya Mar, BOAF,
       Brian and Robert, Frankie Says -> Bowie

    Set 2: Runaway Jim > Moma > Piper -> 2001 > CDT, Loving Cup

    Encore: Coil

    Bowie included Stash teases.

    <https://phish.net/setlists/phish-november-04-1998-mcnichols-arena-denver-co-usa.html>
    ~ ∴ phish-download-show 1998-11-04
    DL% UL%  Dled  Uled  Xfers  Live Total     Current  Left    Speed
    100 --   259M     0     1     0   0:00:33  0:00:38 --:--:-- 8036k
    ~ ∴ ls
    total 8.5K
    drwxr-xr-x 2 somasis users 22 08-20 02:22 'Phish - 1998-11-04 McNichols Arena, Denver, CO [Complete]'/
    ~ ∴ ls Phish\ -\ 1998-11-04\ McNichols\ Arena\,\ Denver\,\ CO\ \[Complete\]/
    total 267M
    -rw-r--r-- 1 somasis users 6.6M 08-20 02:22 '01 Buried Alive.mp3'
    -rw-r--r-- 1 somasis users  14M 07-14 14:44 '02 Character Zero.mp3'
    -rw-r--r-- 1 somasis users  18M 07-14 14:44 '03 Guyute.mp3'
    -rw-r--r-- 1 somasis users  24M 07-14 14:44 '04 Bathtub Gin.mp3'
    -rw-r--r-- 1 somasis users  17M 07-14 14:44 '05 Ya Mar.mp3'
    -rw-r--r-- 1 somasis users  12M 07-14 14:44 '06 Birds of a Feather.mp3'
    -rw-r--r-- 1 somasis users 6.5M 07-14 14:44 '07 Brian and Robert.mp3'
    -rw-r--r-- 1 somasis users  18M 07-14 14:44 '08 Frankie Says.mp3'
    -rw-r--r-- 1 somasis users  25M 07-14 14:44 '09 David Bowie.mp3'
    -rw-r--r-- 1 somasis users  21M 07-14 14:44 '10 Runaway Jim.mp3'
    -rw-r--r-- 1 somasis users  16M 07-14 14:44 '11 The Moma Dance.mp3'
    -rw-r--r-- 1 somasis users  30M 07-14 14:44 '12 Piper.mp3'
    -rw-r--r-- 1 somasis users  16M 07-14 14:44 '13 Also Sprach Zarathustra.mp3'
    -rw-r--r-- 1 somasis users  12M 07-14 14:44 '14 Chalk Dust Torture.mp3'
    -rw-r--r-- 1 somasis users  11M 07-14 14:44 '15 Loving Cup.mp3'
    -rw-r--r-- 1 somasis users  20M 07-14 14:44 '16 The Squirming Coil.mp3'
    -rw-r--r-- 1 somasis users 575K 07-14 14:44  cover.jpg
    -rw-r--r-- 1 somasis users  27K 08-20 02:22  phishin.json
    -rw-r--r-- 1 somasis users  766 07-14 14:44  taper_notes.txt

Or, let's say you want to download the ten most liked shows that Phish
played during the years 1995 to 2008,
and then import those shows into your Beets library:

    ~ ∴ phish-list-shows -d 1995..2008 -S likes_count -n 10 \
        | xargs beet-import-phish

The most complex script is probably `phish-list-shows`,
mostly because I had to figure out
how to structure its usage for the Phish.in API.
But all the tools are pretty simple and basic
and hopefully are easy to understand.

`phish-show-notes` is a nice one,
which uses the [Phish.net] API
to display a show's setlist notes.
It's modeled after the layout of Phish.net's own webpages for notes ([example]).

    ~ ∴ phish-show-notes 1994-05-07
    Phish
    1994-05-07
    1994 Spring Tour
    The Bomb Factory, Dallas, TX, USA

    Set 1: Llama, Horn > Divided, Mound, FEFY > SOAMule, SOAMelt, If I
       Could, Suzy

    Set 2: Loving Cup > Sparkle > Tweezer -> Mind Left Body Jam -> Sparks ->
       Makisupa -> Digital Delay Loop Jam -> Sweet Emotion -> Walk Away ->
       Cannonball -> Purple Rain > HYHU -> Tweeprise

    Encore: Amazing Grace, Sample

    Horn ended with a brief, atypical jam. The jam out of Walk Away included
    a Page solo, teases of It’s Ice and McGrupp, and a Simpsons signal.
    Tweezer was teased in the Sweet Emotion Jam. Amazing Grace was performed
    without microphones. This show was officially released as Live Phish 18.

    <https://phish.net/setlists/phish-may-07-1994-the-bomb-factory-dallas-tx-usa.html>

You can also show the taper notes for the show's recording provided by Phish.in:

    ~ ∴ phish-show-notes -t 1994-05-07
    PHiSH
    05-07-94
    The Bomb Factory, Dallas, TX

    Set I Source: ? > cassette (unknown gen) > SoundBlaster > WAV > CDwave > SHN
    Tracks 7-9 were on side 2 of the cassette and at much lower level.
    I boosted them to 170% ampl. The results are far from perfect but
    this will have to do until someone finds a DAT copy and transfers.

    Set II Source: DSBD > cass0 > DAT
    Transfer: Sony R300 DAT > Zoltrix Nightingale @ 48 kHz > Samplitude 2496 (resampled to 44.1 kHz) > Sound Forge (normalize) > CD Wave > mkwACT 0.97 w/ seeking.  Performed by Rob Garland (rob@allstarupgrades.com)

    Note: The first set and encore of this show do not circulate to the best of my knowledge.

    Set 1
    1.  Llama
    2.  Horn >
    3.  Divided Sky
    4.  Mound
    5.  Fast Enough For You >
    6.  Scent of a Mule
    7.  Split Open and Melt
    8.  If I Could
    9.  Suzie Greenberg

Behold the untapped power of an unemployed music-listening Linux user.

[`beet-import-phish`]: ./bin/beet-import-phish
[`phish-download-show`]: ./bin/phish-download-show
[`phish-list-shows`]: ./bin/phish-list-shows
[`phish-show-notes`]: ./bin/phish-show-notes
[`phishin-auth-token`]: ./bin/phishin-auth-token
[`phishin-like-show`]: ./bin/phishin-like-show
[`phishin-like-track`]: ./bin/phishin-like-track
[Phish]: https://phish.com
[Phish.in]: https://phish.in
[Phish.net]: http://phish.net
[example]: https://phish.net/setlists/phish-may-07-1994-the-bomb-factory-dallas-tx-usa.html

### `upload`

A script for uploading files to services like 0x0.st (which it defaults to).

It was once packaged in nixpkgs,
but it isn't anymore, since the URL to it (in my previous dotfiles repository)
became invalid.
Maybe again someday.

## Machines

### ilo.somas.is

- Etymology: toki pona, meaning tool, machine, device
- Framework Laptop 13, originally purchased 2022-05-06 for $1,549
- History of repair
  - 2022-05-06: original specifications ($1,049)
    - 11th generation Intel i7-1165G7 (12M Cache, up to 4.70 GHz)
      mainboard
    - WD_BLACK SN850 NVMe M.2 2230, 1TB ($199)
    - Intel Wi-Fi 6E AX210 (without vPro) ($18)
    - Corsair DDR4-3200, 32GB (1 &times; 32GB) ($160)
    - 2 &times; HDMI expansion card (1st gen) (2 &times; $19.00)
    - 2 &times; USB-C expansion card (aluminum) (2 &times; $18.00)
    - 2 &times; USB-A expansion card (2 &times; $18.00)
    - 60W Framework power adapter ($49.00)
    - Clear (transparent) ANSI keyboard ($49.00)
    - US English keyboard included (but unused in favor of Clear ANSI
      keyboard)
    - Black bezel included
    - Framework screwdriver included
    - Total: $1,705.89 ($107.39 tax)
  - 2022-05-13: Blank (unlabeled) ANSI keyboard ($49.00)
  - 2022-07-29: sent to Framework for repair service after severe water
    damage during flight; same specs but basically refurbished.
    ($959.00)
  - 2022-08-05: expansion cards to replace water damaged originals
    - 2 &times; USB-C expansion card (aluminum) (2 &times; $18.00)
    - USB-A expansion card ($9.00)
    - HDMI expansion card (1st gen) (19.00)
  - 2023-01-07: fixing a broken fan module
    - Heatsink and fan kit (for Framework Laptop 13, 11th gen Intel)
      ($39.00)
  - 2023-11-25: fixing issues related to mainboard
    - RTC battery - ML1220
  - 2024-03-25: Mainboard replacement due to ongoing issues with 11th
    gen. Intel processors, I think
    - 12th generation Intel i7-1260P mainboard ($549.00)
    - 2024-07-10: Mainboard replacement (again) due to possible lemon
  - 2024-11-13: International English - Linux input cover kit (incl.
    keyboard and touchpad) ($99.00)

## Implementation details

### Secrets (`./secrets`)

I use [agenix] for managing secrets.
Ideally, `age-plugin-tpm` is what provides the machine
and user identities to which the secrets are encrypted.

[agenix]: https://github.com/ryantm/agenix

#### Creating and using a secret

```nix
# secrets.nix
{
  "my-new-apikey.age".publicKeys = [ alice bob computer ];
}
```

    $ agenix -e secrets/my-new-apikey.age

```nix
# Somewhere in a NixOS configuration...
{ self, ...}: {
  age.secrets.my-new-apikey.file = "${self}/secrets/my-new-apikey.age";
}
```

## License

This repository is in the public domain.

To the extent possible under law, Kylie McClain <kylie@somas.is> has
waived all copyright and related or neighboring rights to this work.

<http://creativecommons.org/publicdomain/zero/1.0/>

![RPi pHAT](https://img.shields.io/badge/RPi_pHAT-Keybow-C51A4A.svg?style=flat&logo=raspberrypi)
[![Build Status](https://travis-ci.org/TheDiveO/multibow.svg?branch=feature%2Ftimer)](https://travis-ci.org/TheDiveO/multibow)
![Version](https://img.shields.io/github/tag/thediveo/multibow.svg?style=flat)
![License](https://img.shields.io/github/license/thediveo/multibow.svg?style=flat)
![Lua](https://img.shields.io/badge/Lua-5.3-2C2D72.svg?style=flat&logo=lua)

# Multibow

Find it on GitHub:
[thediveo/multibow](https://github.com/thediveo/multibow).

![Multibow on Keybow](multibow.jpg)

Multibow adds ease-of use support for **multiple layouts** to [Pimoroni
Keybow](https://shop.pimoroni.com/products/keybow) macro keyboards. Simply
switch between the installed layouts by pressing a special key combination
(defaults to press-hold key #11, then tap key #5). And you can even control the key LEDs brightness (press-hold key #11, then tap key #8 to change brightness).

> "_Keybows_" are solderless DIY 4x3 mechanical USB keyboards, powered by a
> Raspberry Pi. And yes, these days even _keyboards_ now run Linux and script
> interpreters...

Features in a nutshell:

- **multiple keyboard layouts**, switchable during operation.
- **three LED brightness levels**, can also be changed during operation.
- supports (multiple) **SHIFT layers** in layouts.
- **self-descriptive keystroke chains**, such as
  `mb.tap("abc").tap(keybow.ENTER)`, including SHIFT/CTRL and repeating
  keystroke sequences or parts thereof. Sending keystroke chains via USB to
  the host is done non-blocking in the background (without multithreading).
- **one-shot and recurring alarms** that run your own keyboard layout
  functions in the background (without multithreading, so no locking and
  threading complexity).

And yes, this is probably a New Year's project slightly gone overboard ...
what sane reason is there to end up with a Lua-scripted multi-layout keyboard
"operating" system and a bunch of automated unit test cases?

## Installation

1. Download the [Pibow
   firmware](https://github.com/pimoroni/keybow-firmware/releases) and copy
   all files inside its `sdcard/` subdirectory onto an empty, FAT32 formatted
   microSD card. Copy only the files **inside** `sdcard/`, but do **not**
   place them into a ~~`sdcard`~~ directory on your microSD card.

2. Download all files from the `sdcard/` subdirectory of this repository and
   then copy them onto the microSD card. This will overwrite but one file
   `key.lua`, all other files are new.
   - download recent stable
     [sdcard.zip](https://minhaskamal.github.io/DownGit/#/home?url=https://github.com/TheDiveO/multibow/tree/master/sdcard)
     – courtesy of Minhas Kamal's incredibly useful
     [DownGit](https://github.com/MinhasKamal/DownGit) service which lets
     users directly download GitHub repository directories as .zip files.
     _Please note that we're not responsible for the DownGit service and its
     integrity, so be cautious when downloading files._

## Multiple Keyboard Layouts

To enable one or more multibow keyboard layouts, edit `sdcard/keys.lua`
accordingly in order to "`require`" them. The default configuration looks as
follows:

```lua
require "layouts/shift" -- for cycling between layouts.
require "layouts/media-player" -- indispensable media player controls.
require "layouts/vsc-golang" -- debugging Go programs in VisualStudio Code.
require "layouts/kdenlive" -- editing video using Kdenlive.
require "layouts/empty" -- empty, do-nothing layout.
```

> You can disable a specific keyboard layout by simply putting two dashes `--`
> in front of the `require "..."`, making it look like `--require "..."`.

## Layouts

The default setup activates the following macro keyboard layouts shown below.

> You can switch (cycle) between them by pressing and holding key #11
> (top-left key in landscape), then tapping key #5 (immediately right to #11),
> and finally releasing both keys.

### Media Player Controls

We start with the probably indispensable media player controls keyboard layout.
'nuff said.

```text
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 11 ┊  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
          🔇     🔈/🔉     🔊
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
                  ⏹️️
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
          ◀️◀️      ▮▶      ▶▶
```

### Debug Go in VisualStudio Code

Debug Go programs and packages in VisualStudio Code with its Go extension.

```text
┌╌╌╌╌┐  ╔════╗  ╔════╗  ╔════╗
┊ 11 ┊  ║  8 ║  ║  5 ║  ║  2 ║
└╌╌╌╌┘  ╚════╝  ╚════╝  ╚════╝
        OUTPUT  DEBUG   CLOSE PANEL
╔════╗  ╔════╗  ╔════╗  ╔════╗
║ 10 ║  ║  7 ║  ║  4 ║  ║  1 ║
╚════╝  ╚════╝  ╚════╝  ╚════╝
  ▶    ⏹STOP   ↺RELOAD  TSTPKG
╔════╗  ╔════╗  ╔════╗  ╔════╗
║  9 ║  ║  6 ║  ║  3 ║  ║  0 ║
╚════╝  ╚════╝  ╚════╝  ╚════╝
  ▮▶    ⮧INTO   ⭢STEP   ⮥OUT
```

- ▶ starts the program without debugging.
- ▮▶ starts, continues, or pauses the program to be debugged.
- ⮧INTO steps _into_ a function call.
- ⭢STEP steps _over_ a line/function call.
- ⏹STOP stops debugging
- ↺RELOAD reloads the program being debugged.
- ☑TSTPKG activates the command "go: test package".
- OUTPUT opens/shows output panel.
- DEBUG opens/shows debug panel.
- CLOSE PANEL ... closes the output/debug panel.

### Kdenlive Video Editor

_coming soon..._

### SHIFT Overlay

This layout provides a SHIFT key. Only when pressed and held, two additional
keys become active for controlling the brightness of the Keybow LEDs and for
switching between multiple keyboard layouts.

Simply pressing and then immediately releasing the SHIFT key without pressing
any of the other keys activates the SHIFT layer in other Multibow keyboard
layouts that are SHIFT-aware.

> **NOTE:** press and hold SHIFT, then use →LAYOUT and 🔆BRIGHT. The SHIFT key
> is always active, regardless of keyboard layout. The other keys in this
> layout become only active _while_ holding SHIFT.

```text
╔════╗  ╔╌╌╌╌╗  ╔╌╌╌╌╗  ┌╌╌╌╌┐
║ 11 ║  ┊  8 ┊  ┊  5 ┊  ┊  2 ┊
╚════╝  ╚╌╌╌╌╝  ╚╌╌╌╌╝  └╌╌╌╌┘
⇑SHIFT  →LAYOUT 🔆BRIGHT
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘

┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
```

- press ⇑SHIFT, release ⇑SHIFT: if a keyboard layout has a SHIFT layer, then
  this activates and deactivates this ⇑SHIFT layer.
- press ⇑SHIFT, tap →LAYOUT, release ⇑SHIFT: switches to next keyboard layout.
- press ⇑SHIFT, tap 🔆BRIGHT, release 🔆BRIGHT: changes the keyboard LED
  brightness in three different brightness steps (70% → 100% → 40% → 70% →
  ...).

### Empty

Just as its name says: an empty keyboard layout – useful if you want to have
also a "no" layout with no functionality whatsoever to switch to. (_This
layout by courtesy of Margaret Thatcher._)

```text
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 11 ┊  ┊  8 ┊  ┊  7 ┊  ┊  6 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊ 10 ┊  ┊  7 ┊  ┊  4 ┊  ┊  1 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐  ┌╌╌╌╌┐
┊  9 ┊  ┊  6 ┊  ┊  3 ┊  ┊  0 ┊
└╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘  └╌╌╌╌┘
```

## Your Own Multikey Keyboard Layout

You may want to start from our template in `layouts/keymap-template.lua`.

1. copy and rename the new layout file name to something more meaningful.

2. edit your new layout file and change its name which is specified in the
   `kmt.name` element:

    ```lua
    km.keymap = {
        -- IMPORTANT: Make sure to change the keymap name to make it unique!
        name="my-cool-layout",
        -- ...
    }
    ```

3. add key definitions for colors and handlers as necessary, see next for examples.

    - you can specify key handlers either "inline", as you can see from the
      example mapping for key #0:

      ```lua
      km.keymap = {
        -- ...
        [0] = { c={r=1, g=1, b=1}, press=function() mb.keys.tap("a") end},
      }
      ```

      This sets the key #0's LED color to white, and emits an "a" press everytime
      you tap key #0.

    - for more complex handling, you may want to use a dedicated function instead:

      ```lua
      function km.mypress(keyno)
        mb.keys.tap("a")
      end

      km.keymap = {
        -- ...
        [1] = { c={r=1, g=1, b=1}, press=km.mypress}
      }

    - you can also do things on key releases:

      ```lua
      km.keymap = {
        -- ...
        [2] = { c={r=1, g=1, b=1}, release=function() mb.keys.tap("x") end},
      }
      ```

For more details and examples, please have a look at the keyboard layouts in
`layouts/vsc-golang.lua` and `layouts/kdenlive.lua`.

## Keystroke Chains

Multibow features describing the keystrokes to be sent via USB to a host
using so-called keystroke operation chains. Those who have worked with
assertion libraries, such as [luassert](https://github.com/Olivine-Labs/luassert)
will notice the influence here.

You simply start from `mb.keys.`... and then tack on the keystrokes you want to send.
Simply chain multiple keystroke operations together, such as when typing "multibow"
and then pressing the ENTER key:

```lua
mb.keys.tap("multibow").tap(keybow.ENTER)
```

Please note that keystroke operations, such as `tap()` can be spelled not only in
lowercase, but also in MixedCase and UPPERCASE, as you like. This is actually a neat
trick to allow tapping the END key by simply writing `End`, when `end` would be an
invalid operation because it's a reserved word in Lua:

```lua
mb.keys.End()
```

- `tap("abc")` and `tap(keybow.ENTER)`: taps a string of characters, or a single key,
  such as the ENTER key. Tapping here means first pressing a certain, then releasing
  this key, and only then proceed with the next key to be tapped.

  ```lua
  mb.keys.tap("multibow").tap(keybow.ENTER)
  ```

- `left()`, `right()`, `up()`, and `down()`: taps the corresponding cursor arrow key.
  You can drop the `()` unless you arrow key tap is the last element in a keystroke
  chain (due to restrictions in Lua).

- `home()` and `End()`: HOME and END keys, you get the drift. Since `end` is a reserved
  word in Lua, you cannot use `end()` but must use `End` instead.

- `shift()`, `control()`, `alt()`, `meta()`: presses and holds the SHIFT/CTRL/ALT/META
  modifier key while tapping the following keystrokes, and releases the SHIFT/CTRL
  modifier afterwards. All chained keystrokes following are enclosed by these keyboard
  modifiers until the end of the chain, or alternatively a `fin` chain element (see
  below for details). Multiple modifiers can be chained as usual.

  ```lua
  mb.keys.tap("multibow").ctrl.shift.tap(keybow.ENTER)
  ```

- `mod(m, ...)`: presses and holds a set of keyboard modifiers (SHIFT, CTRL, ...) while
  tapping the following keystrokes, and releases the keyboard modifiers thereafter. All
  following keystroke chain elements are enclosed, or until the next `fin` in the chain.
  Depending on your preferences, you might want to use `shift`, `ctrl` instead.

  ```lua
  mb.keys.mod(keybow.LEFT_SHIFT, keybow.LEFT_CTRL).tap("multibow")
  ```

- `times(x)` and `times(x)`...`fin`...: repeats the following keystroke chain the
  specified number of times. The following chain either ends implicitly at the end
  of this keystroke chain, or alternatively at any earlier point using the `fin()`
  element. Pro tip: you can drop the function call brackets to save, erm, keystrokes.

- `fin()` and `done`: terminates a sub chain, started by `mod()`, `shift()`, `ctrl()`, and
  `times()`. This allows for convenient and highly self-descriptive single-liners,
  such as:

  ```lua
  mb.keys.ctrl.tap(keybow.ENTER).fin.tap("multibow")
  ```

## Licenses

Multibow is (c) 2019 Harald Albrecht and is licensed under the MIT license, see
the [LICENSE](LICENSE) file.

The file `keybow.lua` included from
[pimoroni/keybow-firmware](https://github.com/pimoroni/keybow-firmware) for
testing purposes is licensed under the MIT license, as declared by Pimoroni's
keybow-firmware GitHub repository.

## Developing/Hacking

Whether you want to dry-run your own keyboard layout or to hack Multibow: use
the unit tests which you can find in the `spec/` subdirectory. These tests
help you in detecting syntax and logic errors early, avoiding the
rinse-and-repeat cycle with copying to microSD card, starting the Keybow
hardware, and then wondering what went wrong, without any real clue as to what
is the cause of failure.

> **Note:** before `check.sh` runs all tests and lints multibow, it installs
> a local Lua 5.3 environment including luarocks and the required luarock packages,
> if not already done so. This local environment will be placed into `./env`.

### Visual Studio Code

There's a [Visual Studio Code](https://code.visualstudio.com/) workspace
`multibow.code-workspace` in the `.vscode/` directory inside this repository.
It defines a default build task which lints everything, as well as a default
test task which runs all tests.

### Shell

Simply run `./check.sh` while in the `multibow` repository root directory to run
all tests and linting.

If you want to just test a certain file or directory, then run `busted
spec/layout/kdenlive_spec.lua` to unit test a specific keyboard layout
(or set of layouts) or `./env.sh busted spec/layouts` to check all layouts.

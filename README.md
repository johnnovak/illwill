# illwill

## Overview

**illwill** is a *(n)curses* inspired simple terminal library that aims to make
writing cross-platform text mode applications easy. Having said that, it's
much simpler than (n)curses and it's not as robust by far in terms of
supporting different encodings, terminal types, etc. The aim was to write
something small and simple in pure Nim that works for 99% of users without
requiring any external dependencies or a terminfo database.

For "serious" applications, the best is always to write different backends for
*nix and Windows (one of the main reasons being that the Windows Console is
buffer based, not file based). But I think this library is perfect for small
cross-platform programs and utilities where you need something more than the
basic blocking console I/O, but you don't actually want to bother with
a full-blown GUI.

### Main features

* **Non-blocking** keyboard input.
* Support for **key combinations** and **special keys** available both in the standard
  Windows Console (`cmd.exe`) and most common POSIX terminals.
* **Virtual terminal buffers** with **double-buffering** support (only display changes
  from the previous frame and minimise the number of attribute changes to
  reduce CPU usage).
* Simple graphics using **UTF-8 box drawing** symbols.
* **Full-screen support** with restoring the contents of the terminal after exit.
* **Mouse support** with modifier key reporting.
* **No dependencies**—only depends on the standard terminal module.

<img src="https://github.com/johnnovak/illwill/raw/master/img/nim-mod-1.png" align="left" width="48%" alt="illwill in action" />
<img src="https://github.com/johnnovak/illwill/raw/master/img/nim-mod-2.png" width="48%" alt="illwill in action" />

<p align="center"><em>
<a href="https://github.com/johnnovak/nim-mod">nim-mod</a> is an oldschool MOD
player that uses illwill for its awesome text-mode user interface</em></p>


### Use it if

* You just want something simple that lets you write full-screen terminal
  apps with non-blocking keyboard input that work on Windows, Mac OS X and
  99.99% of modern Linux distributions.
* You don't need to support any fancy encodings and terminal types other than
  UTF-8.
* You're developing a custom UI so you don't need any predefined widgets.
* You don't mind the [immediate mode UI](https://github.com/ocornut/imgui)
  style/approach.
* You absolutely don't want any external dependencies.

### Projects using illwill

- [nim-mod](https://github.com/johnnovak/nim-mod) — A Nim MOD player just for fun 
- [ttop](https://github.com/inv2004/ttop) — System monitoring tool with historical data service, triggers and top-like TUI
- [promexplorer](https://github.com/marcusramberg/promexplorer) — A simple tool to explore Prometheus exporter metrics
- [clipclap](https://github.com/tttardigrado/clipclap) — A terminal-based ClipBoard Manager written in Nim
- [illwillWidgets](https://github.com/enthus1ast/illwillWidgets) — Mouse enabled widgets for illwill
- [tui_widget](https://github.com/jaar23/tui_widget) — Terminal UI widgets based on illwill
- [nimSnake](https://github.com/ColTrez/nimSnake) — Classic game of snake implemented in nim using the illwill TUI library for graphics

### Don't use it if

* You need ultimate robustness in terms of supporting obscure terminals,
  character encodings and Linux/Unix distributions.
* You need predefined widgets.
* You like complicating your life :sunglasses:

### Limitations & known issues

* Suspend/resume (SIGTSTP/SIGCONT handling) works, but it doesn't properly
  reset the terminal when suspending the app.
* The contents of the terminal is not restored after exiting a full-screen app
  on Windows.

## Installation

The best way to install the library is by using
[nimble](https://github.com/nim-lang/nimble):

```
nimble install illwill
```

## Documentation

https://www.johnnovak.net/illwill/


## Usage

This is a simple example on the general structure of a fullscreen terminal
application. Check out the [examples](/examples) for more advanced use cases
(e.g. using box drawing buffers, handling terminal resizes, etc.)


```nimrod
import os, strutils
import illwill

# 1. Initialise terminal in fullscreen mode and make sure we restore the state
# of the terminal state when exiting.
proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

illwillInit(fullscreen=true)
setControlCHook(exitProc)
hideCursor()

# 2. We will construct the next frame to be displayed in this buffer and then
# just instruct the library to display its contents to the actual terminal
# (double buffering is enabled by default; only the differences from the
# previous frame will be actually printed to the terminal).
var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

# 3. Display some simple static UI that doesn't change from frame to frame.
tb.setForegroundColor(fgBlack, true)
tb.drawRect(0, 0, 40, 5)
tb.drawHorizLine(2, 38, 3, doubleStyle=true)

tb.write(2, 1, fgWhite, "Press any key to display its name")
tb.write(2, 2, "Press ", fgYellow, "ESC", fgWhite,
               " or ", fgYellow, "Q", fgWhite, " to quit")

# 4. This is how the main event loop typically looks like: we keep polling for
# user input (keypress events), do something based on the input, modify the
# contents of the terminal buffer (if necessary), and then display the new
# frame.
while true:
  var key = getKey()
  case key
  of Key.None: discard
  of Key.Escape, Key.Q: exitProc()
  else:
    tb.write(8, 4, ' '.repeat(31))
    tb.write(2, 4, resetStyle, "Key pressed: ", fgGreen, $key)

  tb.display()
  sleep(20)

```

## License

Copyright © 2018-2024 John Novak <<john@johnnovak.net>>

This work is free. You can redistribute it and/or modify it under the terms of
the [Do What The Fuck You Want To Public License, Version 2](http://www.wtfpl.net/), as published
by Sam Hocevar. See the [COPYING](./COPYING) file for more details.


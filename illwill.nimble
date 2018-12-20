# Package

version       = "0.1.0"
author        = "John Novak"
description   = "A curses inspired simple cross-platform console library for Nim"
license       = "MIT"

skipDirs = @["examples", "img"]

# Dependencies

requires "nim >= 0.18.0"

task examples, "Compiles the examples":
  exec "nim c -d:release examples/boxdrawing.nim"
  exec "nim c -d:release examples/drawtest.nim"
  exec "nim c -d:release examples/fullscreen.nim"
  exec "nim c -d:release examples/keycodes.nim"
  exec "nim c -d:release examples/simplekeycodes.nim"

task examplesDebug, "Compiles the examples (debug mode)":
  exec "nim c examples/boxdrawing.nim"
  exec "nim c examples/drawtest.nim"
  exec "nim c examples/fullscreen.nim"
  exec "nim c examples/keycodes.nim"
  exec "nim c examples/simplekeycodes.nim"

task gendoc, "Generate HTML documentation":
  exec "nim doc -o:doc/illwill.html illwill"


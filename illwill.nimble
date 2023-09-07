# Package

version       = "0.3.1"
author        = "John Novak <john@johnnovak.net>"
description   = "A curses inspired simple cross-platform console library for Nim"
license       = "WTFPL"

skipDirs = @["doc", "examples", "img"]

# Dependencies

requires "nim >= 1.6.10"

task examples, "Compiles the examples":
  exec "nim c -d:release examples/boxdrawing.nim"
  exec "nim c -d:release examples/drawtest.nim"
  exec "nim c -d:release examples/fullscreen.nim"
  exec "nim c -d:release examples/keycodes.nim"
  exec "nim c -d:release examples/readmeexample.nim"
  exec "nim c -d:release examples/simplekeycodes.nim"
  exec "nim c -d:release examples/mouse.nim"
  exec "nim c -d:release examples/mouseMinimal.nim"
  exec "nim c -d:release examples/transparency.nim"

task examplesDebug, "Compiles the examples (debug mode)":
  exec "nim c examples/boxdrawing.nim"
  exec "nim c examples/drawtest.nim"
  exec "nim c examples/fullscreen.nim"
  exec "nim c examples/keycodes.nim"
  exec "nim c examples/readmeexample.nim"
  exec "nim c examples/simplekeycodes.nim"
  exec "nim c examples/mouse.nim"
  exec "nim c examples/transparency.nim"

task docgen, "Generate HTML documentation":
  exec "nim doc -o:doc/illwill.html illwill"


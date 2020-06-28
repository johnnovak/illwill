# Package

version       = "0.2.0"
author        = "John Novak <john@johnnovak.net>"
description   = "A curses inspired simple cross-platform console library for Nim"
license       = "WTFPL"

skipDirs = @["doc", "examples", "img"]

# Dependencies

requires "nim >= 0.20.0"

task examples, "Compiles the examples":
  exec "nim c -d:release examples/boxdrawing.nim"
  exec "nim c -d:release examples/drawtest.nim"
  exec "nim c -d:release examples/fullscreen.nim"
  exec "nim c -d:release examples/keycodes.nim"
  exec "nim c -d:release examples/readmeexample.nim"
  exec "nim c -d:release examples/simplekeycodes.nim"
  exec "nim c -d:release examples/mouse.nim"
  exec "nim c -d:release examples/mouseMinimal.nim"

task examplesDebug, "Compiles the examples (debug mode)":
  exec "nim c examples/boxdrawing.nim"
  exec "nim c examples/drawtest.nim"
  exec "nim c examples/fullscreen.nim"
  exec "nim c examples/keycodes.nim"
  exec "nim c examples/readmeexample.nim"
  exec "nim c examples/simplekeycodes.nim"
  exec "nim c examples/mouse.nim"
  exec "nim c examples/mouseMinimal.nim"

task docgen, "Generate HTML documentation":
  exec "nim doc --d:docgenonly -o:doc/illwill.html illwill.nim"


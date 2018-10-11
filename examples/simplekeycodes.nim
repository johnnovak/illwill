# Simple non-full-screen example that prints out keycode enums of the keys
# pressed on the keyboard

import os
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit()
  quit(0)

proc main() =
  setControlCHook(exitProc)
  illwillInit(fullscreen = false)

  echo "-----------------------------------------------------------------"
  echo "Press keys/key combinations on the keyboard to view their keycode"
  echo "Press Ctrl-C to quit"
  echo "-----------------------------------------------------------------"

  while true:
    var key = getKey()
    if key != Key.None:
      echo key
    else:
      sleep(20)

main()

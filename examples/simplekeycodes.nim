# Simple non-full-screen example that prints out keycode enums of the keys
# pressed on the keyboard.
#
# Note that although echo, write and the terminal module should not be used
# when using illwill in fullscreen mode, in non-fullscreen mode it's okay to
# use them. In such case illwill is typically used for non-blocking keyboard
# input only, so it's best to import only the functions needed for that, as
# shown below. This way there will be no symbol name clashes when importing
# the terminal module (e.g. the foreground and background color enums).
#
# This example will not work in javascript as it is dependent on the 'terminal'
# library.

import os, terminal
from illwill import illwillInit, illwillDeinit, getKey, Key, timerLoop

proc exitProc() {.noconv.} =
  illwillDeinit()
  quit(0)

proc main() =
  setControlCHook(exitProc)
  illwillInit(fullscreen=false)

  setForegroundColor(fgWhite)
  setStyle({styleDim})
  echo "-----------------------------------------------------------------"

  resetAttributes()
  setForegroundColor(fgYellow)
  echo "Press keys/key combinations on the keyboard to view their keycode"

  setForegroundColor(fgRed)
  echo "Press Ctrl-C to quit"

  setForegroundColor(fgWhite)
  setStyle({styleDim})
  echo "-----------------------------------------------------------------"

  setForegroundColor(fgWhite)
  setStyle({styleDim})

  resetAttributes()

  timerLoop(20):
    var key = getKey()
    if key != Key.None:
      echo key

main()

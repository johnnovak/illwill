# This is the example code from the README.

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
var cb = newTerminalBuffer(terminalWidth(), terminalHeight())

# 3. Display some simple static UI that doesn't change from frame to frame.
cb.setForegroundColor(fgBlack, true)
cb.drawRect(0, 0, 40, 5)
cb.drawHorizLine(2, 38, 3, doubleStyle=true)

cb.write(2, 1, fgWhite, "Press any key to display its name")
cb.write(2, 2, "Press ", fgYellow, "ESC", fgWhite,
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
    cb.write(8, 4, ' '.repeat(31))
    cb.write(2, 4, resetStyle, "Key pressed: ", fgGreen, $key)

  cb.display()
  sleep(20)


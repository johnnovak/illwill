# Example that prints out keycode enums of the keys pressed on the keyboard
# and demonstrates the basic structure of a full-screen app

import math, os, strformat, times
import illwill


proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

var gLastKeyPressed = Key.None

proc updateScreen(tb: var TerminalBuffer) =
  let
    x1 = 3
    y1 = 1
    x2 = max(tb.width-4, x1)
    y2 = max(tb.height-2, y1)
    fillChars = "|/-\\"

  let t = epochTime()
  let ch = fillChars[((t * 5) mod fillChars.len.float).int]

  tb.setForegroundColor(fgBlack, bright=true)
  tb.fill(x1,y1, x2, y2, $ch)

  tb.setForegroundColor(fgWhite)
  tb.drawRect(x1, y1, x2, y2)

  tb.setForegroundColor(fgWhite, bright=true)
  tb.write(x1+1, y1+1, "Press keys/key combinations on the keyboard to view their keycode")
  tb.write(x1+1, y1+2, "Press Q, Esc or Ctrl-C to quit")
  tb.write(x1+1, y1+4, "Resize the terminal window and see what happens :)")

  let
    text = " Key pressed:                 "
    tx = max(x1 + ((x2 - x1 - text.len) / 2).int, 0)
    ty = max(y1 + ((y2 - y1) / 2).int, 0)

  tb.setBackgroundColor(bgRed)
  tb.setForegroundColor(fgYellow)
  tb.drawRect(tx-1, ty-1, tx + text.len, ty+1, doubleStyle=true)

  tb.write(tx, ty, text)

  tb.setForegroundColor(fgWhite, bright=true)
  tb.write(tx+14, ty, $gLastKeyPressed)


proc main() =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

  timerLoop(50):
    var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

    var key = getKey()
    case key
    of Key.None: discard
    of Key.Escape, Key.Q: exitProc()
    else: gLastKeyPressed = key

    tb.updateScreen()
    tb.display()

main()


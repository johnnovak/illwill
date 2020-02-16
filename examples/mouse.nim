import os, strutils
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

illwillInit(fullscreen=true, mouse=true)
setControlCHook(exitProc)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

while true:
  tb.write(0, 0, fgWhite, styleBright, "Draw with left/right/middle click; ctrl will brighten up the draw.")
  tb.write(0, 1, "Press Q or Ctrl-C to quit")
  var key = getKey()
  case key
  of Key.None: discard
  of Key.Escape, Key.Q: exitProc()
  of Key.Mouse:
    let mi = getMouse()
    if mi.action == MouseButtonAction.ActionPressed:
      case mi.button
      of ButtonLeft:
        if mi.ctrl:
          tb.write mi.x, mi.y, fgRed, styleBright, "♥"
        else:
          tb.write mi.x, mi.y, fgRed, styleDim , "♥"
      of ButtonMiddle:
        tb.write mi.x, mi.y, fgBlue, "◉"
      of ButtonRight:
        tb.write mi.x, mi.y, fgCyan, "#"
      else: discard
    elif mi.action == MouseButtonAction.ActionReleased:
      tb.write mi.x, mi.y, "^"
  else:
    echo key
    discard

  tb.display()
  sleep(10)

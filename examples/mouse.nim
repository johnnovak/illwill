import os, strutils
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

illwillInit(fullscreen=true, mouse = true)
setControlCHook(exitProc)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

while true:
  var key = getKey()
  case key
  of Key.None: discard
  of Key.Escape, Key.Q: exitProc()
  of Key.Mouse:
    let mi = getMouse()
    if mi.action == MouseButtonAction.Pressed:
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
    else:
      tb.write mi.x, mi.y, "^"
  else:
    echo key
    discard

  tb.display()
  sleep(20)

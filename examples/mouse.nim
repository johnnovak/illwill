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
  var key = getKey()
  case key
  of Key.None: discard
  of Key.Escape, Key.Q: exitProc()
  of Key.Mouse:
    let mouse = getMouse()
    # echo mouse
    if mouse.action == MouseButtonAction.Pressed:
      tb.write mouse.x, mouse.y, "#"
    else:
      tb.write mouse.x, mouse.y, "^"
  else:
    echo key
    discard

  tb.display()
  sleep(20)

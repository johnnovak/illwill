import illwill, os

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

setControlCHook(exitProc)
illwillInit(mouse=true)

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

while true:
  var key = getKey()
  if key == Key.Mouse:
    echo getMouse()
  tb.display()
  sleep(10)

import illwill, os

illwillInit(fullscreen = true, mouse = true)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

while true:
  var key = getKey()
  if key == Key.Mouse:
    let mi = getMouse()
    if mi.action == MouseButtonAction.ActionPressed:
      tb.write mi.x, mi.y, fgRed, styleBright, "♥"

  tb.display()
  sleep(20)

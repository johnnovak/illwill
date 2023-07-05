
import os, random
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit(); showCursor()
  quit(0)

illwillInit(fullscreen=true, mouse=true)
setControlCHook(exitProc); hideCursor()

var
  x, y: int
  (width, height) = terminalSize()
  tb = newTerminalBuffer(width, height)
  tb2 = newTerminalBuffer(width, height)
  bb = newBoxBuffer(width, height)
  box = newTerminalBuffer(16,3)
  mi: MouseInfo
  (posx, posy) = (40, 20)

box.write(1, 0, "HELLO! IS THERE")
box.write(1, 1, "ANYBODY")
box.write(1, 2, "OUT THERE?")

while true:
  tb.clear()
  bb = newBoxBuffer(width, height)
  tb.copyFrom(tb2)
  bb.drawRect(posx,posy,posx+23,posy+4)
  tb.write(bb)
  tb.copyFrom(box, 0, 0, 24, 5, posx+4, posy+1, transparency=true)

  (x, y) = (rand (1..width), rand (1..height))

  if rand(1..20) == 6: tb2.write(x, y, "*")
  else: tb2.write(x, y, " ")

  var key = getKey()
  case key
    of Key.None: discard
    of Key.Escape, Key.Q: exitProc()
    of Key.Mouse:
      mi = getMouse()
      case mi.button
      of mbLeft:
        (posx, posy) = (mi.x, mi.y)
      else: discard
    else: discard

  tb.display()

  sleep(10)

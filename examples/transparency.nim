import os, random
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit();
  showCursor()
  quit(0)

var
  gBufferStars = newTerminalBuffer(terminalWidth(), terminalHeight())
  gBufferBox   = newTerminalBuffer(30, 11)
  gPosX = 20
  gPosY = 10
  gTransparency = true


proc updateScreen(tb: var TerminalBuffer) =
  # Update stars
  let s = if rand(1..15) == 1: "*" else: " "
  let (x, y) = (rand(tb.width-1), rand(tb.height-1))
  gBufferStars.write(x, y, s)

  tb.copyFrom(gBufferStars)
  tb.copyFrom(gBufferBox, 0, 0, gBufferBox.width, gBufferBox.height,
              gPosX, gPosY, transparency=gTransparency)

  tb.write(0, 0, "Use the H/J/K/L keys, the arrow keys, or the mouse to move the box")
  tb.write(0, 1, "Press T to toggle transparency")
  tb.write(0, 2, "Press Q or Ctrl-C to quit")

  tb.write(0, 4, "Transparency: " & (if gTransparency: "on" else: "off"))


proc main() =
  illwillInit(fullscreen=true, mouse=true)
  setControlCHook(exitProc); hideCursor()
  hideCursor()

  gBufferBox.write(7, 3, "HELLO! IS THERE")
  gBufferBox.write(8, 5, "A N Y B O D Y")
  gBufferBox.write(9, 7, "OUT THERE?")
  gBufferBox.drawRect(0, 0, gBufferBox.width-1, gBufferBox.height-1)

  var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

  while true:
    var key = getKey()
    case key
      of Key.None: discard
      of Key.Escape, Key.Q: exitProc()

      of Key.Left,  Key.H: gPosX = max(gPosX-1, 0)
      of Key.Right, Key.L: gPosX = min(gPosX+1, tb.width-1)
      of Key.Up,    Key.K: gPosY = max(gPosY-1, 0)
      of Key.Down,  Key.J: gPosY = min(gPosY+1, tb.height-1)

      of Key.T: gTransparency = not gTransparency

      of Key.Mouse:
        let mi = getMouse()
        case mi.button
        of mbLeft:
          (gPosX, gPosY) = (mi.x, mi.y)
        else: discard
      else: discard

    tb.updateScreen()
    tb.display()

    sleep(20)

main()


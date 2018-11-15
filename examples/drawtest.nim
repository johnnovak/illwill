# Full-screen example to demonstrate the box drawing functionality

import os, strformat
import illwill


proc exitProc() {.noconv.} =
  illwillDeinit()
  quit(0)


type
  Direction = enum
    Left, Right, Up, Down

  Mode = enum
    Draw, Move

var gBoxBuffer = newBoxBuffer(terminalWidth(), terminalHeight())

var
  gCurrX = (terminalWidth() / 2 - 1).int
  gCurrY = (terminalHeight() / 2 - 1).int
  gDrawMode = Draw
  gDoubleStyle = false

proc draw(dir: Direction) =
  case dir
  of Direction.Left:
    let x = max(gCurrX-1, 0)
    gBoxBuffer.drawHorizLine(gCurrX, x, gCurrY, gDoubleStyle)
    gCurrX = x

  of Direction.Right:
    let x = min(gCurrX+1, terminalWidth()-1)
    gBoxBuffer.drawHorizLine(gCurrX, x, gCurrY, gDoubleStyle)
    gCurrX = x

  of Direction.Up:
    let y = max(gCurrY-1, 0)
    gBoxBuffer.drawVertLine(gCurrX, gCurrY, y, gDoubleStyle)
    gCurrY = y

  of Direction.Down:
    let y = min(gCurrY+1, terminalHeight()-1)
    gBoxBuffer.drawVertLine(gCurrX, gCurrY, y, gDoubleStyle)
    gCurrY = y


proc updateScreen(tb: var TerminalBuffer) =
  tb.write(0, 0, "Use the H/J/K/L or arrow keys to move the cursor")
  tb.write(0, 1, "Press Q or Ctrl-C to quit")

  let lineStyle = if gDoubleStyle: "Double" else: "Single"
  tb.write(0, 3, fmt"Line style (S):  {lineStyle}")
  tb.write(0, 4, fmt"Draw mode  (D):  {gDrawMode}")

  tb.setForegroundColor(fgGreen)
  tb.write(gBoxBuffer)
  tb.setForegroundColor(fgRed)

  case gDrawMode
  of Draw: tb.write(gCurrX, gCurrY, "*")
  of Move: tb.write(gCurrX, gCurrY, "o")


proc main() =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

  while true:
    var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

    if tb.width > gBoxBuffer.width or tb.height > gBoxBuffer.height:
      var bb = newBoxBuffer(tb.width, tb.height)
      bb.copyFrom(gBoxBuffer)
      gBoxBuffer = bb

    var key = getKey()
    case key
    of Key.Left,  Key.H:
      if gDrawMode == Draw: draw(Direction.Left)
      else: gCurrX = max(gCurrX-1, 0)

    of Key.Right, Key.L:
      if gDrawMode == Draw: draw(Direction.Right)
      else: gCurrX = min(gCurrX+1, tb.width-1)

    of Key.Up,    Key.K:
      if gDrawMode == Draw: draw(Direction.Up)
      else: gCurrY = max(gCurrY-1, 0)

    of Key.Down,  Key.J:
      if gDrawMode == Draw: draw(Direction.Down)
      else: gCurrY = min(gCurrY+1, tb.height-1)

    of Key.S: gDoubleStyle = not gDoubleStyle

    of Key.D:
      if gDrawMode == Draw: gDrawMode = Move
      else: gDrawMode = Draw

    of Key.Q: exitProc(); break
    else: discard

    tb.updateScreen()
    tb.display()

    sleep(20)

main()


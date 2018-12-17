# Example demonstrating the various box drawing methods.

import illwill
import os


proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc main() =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

  while true:
    var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

    var key = getKey()
    case key
    of Key.Escape, Key.Q: exitProc()
    else: discard

    tb.write(0, 0, "Press Q, Esc or Ctrl-C to quit")

    # (1) TerminalBuffer.drawRect doesn't connect overlapping lines
    tb.setForegroundColor(fgGreen)
    tb.drawRect(2, 3, 14, 5, doubleStyle=true)
    tb.drawRect(6, 2, 10, 6)

    tb.write(7, 7, fgWhite, "(1)")

    # (2) BoxBuffer.drawRect, however, does by default
    var bb = newBoxBuffer(tb.width, tb.height)
    bb.drawRect(20, 3, 32, 5, doubleStyle=true)
    bb.drawRect(24, 2, 28, 6)
    tb.setForegroundColor(fgBlue)
    tb.write(bb)

    tb.write(25, 7, fgWhite, "(2)")

    # (3) BoxBuffer.drawRect with connect=false
    bb = newBoxBuffer(tb.width, tb.height)
    bb.drawRect(38, 3, 50, 5, doubleStyle=true, connect=false)
    bb.drawRect(42, 2, 46, 6, connect=false)
    tb.setForegroundColor(fgRed)
    tb.write(bb)

    tb.write(43, 7, fgWhite, "(3)")

    # (4) Smallest possible rectangle to draw
    tb.setForegroundColor(fgWhite)
    tb.drawRect(7, 9, 8, 10)

    tb.write(7, 11, fgWhite, "(4)")

    # (5) Rectangle too small, draw nothing
    tb.setForegroundColor(fgMagenta)
    tb.drawRect(25, 9, 25, 9)

    tb.write(25, 11, fgWhite, "(5)")

    # (6) TerminalBuffer.drawHorizLine/drawVertLine doesn't connect
    # overlapping lines
    tb.setForegroundColor(fgYellow)
    tb.drawHorizLine(2, 14, 14, doubleStyle=true)
    tb.drawVertLine(4, 13, 15, doubleStyle=true)
    tb.drawVertLine(6, 13, 15)
    tb.drawVertLine(10, 13, 16)
    tb.drawHorizLine(4, 12, 15, doubleStyle=true)

    tb.write(7, 17, fgWhite, "(6)")

    # (7) TerminalBuffer.drawHorizLine/drawVertLine does connect
    # overlapping lines by default
    bb = newBoxBuffer(tb.width, tb.height)
    bb.drawHorizLine(20, 32, 14, doubleStyle=true)
    bb.drawVertLine(22, 13, 15, doubleStyle=true)
    bb.drawVertLine(24, 13, 15)
    bb.drawVertLine(28, 13, 16)
    bb.drawHorizLine(22, 30, 15, doubleStyle=true)
    tb.setForegroundColor(fgCyan)
    tb.write(bb)

    tb.write(25, 17, fgWhite, "(7)")

    # (8) TerminalBuffer.drawHorizLine/drawVertLine does connect
    # overlapping lines by default
    bb = newBoxBuffer(tb.width, tb.height)
    bb.drawHorizLine(38, 50, 14, doubleStyle=true, connect=false)
    bb.drawVertLine(40, 13, 15, doubleStyle=true, connect=false)
    bb.drawVertLine(42, 13, 15, connect=false)
    bb.drawVertLine(46, 13, 16, connect=false)
    bb.drawHorizLine(40, 48, 15, doubleStyle=true, connect=false)
    tb.setForegroundColor(fgMagenta)
    tb.write(bb)

    tb.write(43, 17, fgWhite, "(8)")

    tb.write(0, 20,
             "Check the source code for the description of the test cases ")

    tb.display()

    sleep(20)

main()


# This is the example code from the README.

import os, strutils
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

illwillInit(fullscreen=true)
setControlCHook(exitProc)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

tb.write(26, 0, "COLOR AND STYLE EXAMPLES")

var i = 2

tb.write(0, i, resetStyle, fgNone, bgNone, "plain on black background")
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "plain on blue background", bgBlue)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "hidden on blue background", bgBlue, styleHidden)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "dim on blue background", bgBlue, styleDim)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "bright on black background", styleBright)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "dim on black background", styleDim)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "italic on black background", styleItalic)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "blink on black background", styleBlink)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "underscore on black background", styleUnderscore)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "strikethrough on black background", styleStrikethrough)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "i/u/s on black background", styleStrikethrough, styleUnderscore, styleItalic)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "reverse on black background", styleReverse)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

tb.write(0, i, resetStyle, fgNone, bgNone, "reverse on green background", bgGreen, styleReverse)
tb.write(30, i, fgBlack, "Black ", fgRed, "Red ", fgGreen, "Green ")
tb.write(fgYellow, "Yellow ", fgBlue, "Blue ", fgMagenta, "Magenta ")
tb.write(fgCyan, "Cyan ", fgWhite, "White")
i += 1

timerLoop(20):
  tb.display()

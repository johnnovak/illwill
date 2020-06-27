import illwill

illwillInit(fullscreen=false)
hideCursor()

proc exitProc() {.noconv.} =
  illwillDeinit()
  echo "exit proc called"
  quit(0)

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

setControlCHook(exitProc)

tb.write(10, 3, fgYellow, "SAMPLE SURVEY")
tb.write(0, 7, fgGreen, "1.", fgWhite, " Favorite color: ", bgBlue, "                     ", bgBlack)
tb.write(0, 9, fgGreen, "2.", fgWhite, " Favorite sound: ", bgBlue, "                     ")

let qsize = "1. Favorite color: ".len

tb.display()

var step = 1

var answer1 = ""
var answer2 = ""

timerLoop(20): # make sure each loop finishes in 20 ms or less
  case step:
  of 1:
    tb.setForegroundColor(fgGreen, true)
    tb.startInputLine(qsize, 7, "", 20)
    step = 2
  of 2:
    if tb.inputLineReady():
      answer1 = getInputLineText()
      step = 3
  of 3:
    tb.startInputLine(qsize, 9, "zippity", 20)
    step = 4
  of 4:
    if tb.inputLineReady():
      answer2 = getInputLineText()
      step = 5
  of 5:
    tb.write(0, 15, fgYellow, bgBlack, "Thank you!")
    tb.write(0, 18, fgYellow, "We will use your answers of \"" & answer1)
    tb.write("\" and \"" & answer2 & "\"")
    step = 6
  else:
    tb.setCursorPos(0, 20)
    showCursor()
    exitProc()
  tb.display()

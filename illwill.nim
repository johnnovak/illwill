import os, strformat, terminal, unicode

export terminal


const keyNone* = -1

const keyCtrlA* = 1
const keyCtrlB* = 2
const keyCtrlD* = 4
const keyCtrlE* = 5
const keyCtrlF* = 6
const keyCtrlG* = 7
const keyCtrlH* = 8
const keyCtrlJ* = 10
const keyCtrlK* = 11
const keyCtrlL* = 12
const keyCtrlN* = 14
const keyCtrlO* = 15
const keyCtrlP* = 16
const keyCtrlQ* = 17
const keyCtrlR* = 18
const keyCtrlS* = 19
const keyCtrlT* = 20
const keyCtrlU* = 21
const keyCtrlV* = 22
const keyCtrlW* = 23
const keyCtrlX* = 24
const keyCtrlY* = 25
const keyCtrlZ* = 26

const keyCtrlBackslash*    = 28
const keyCtrlCloseBracket* = 29

const keyTab*        = 9
const keyEnter*      = 13
const keyEscape*     = 27
const keySpace*      = 32
const keyBackspace*  = 127

const keyUp*    = 1001
const keyDown*  = 1002
const keyRight* = 1003
const keyLeft*  = 1004

const keyHome*       = 1005
const keyInsert*     = 1006
const keyDelete*     = 1007
const keyEnd*        = 1008
const keyPageUp*     = 1009
const keyPageDown*   = 1010

const keyF1*         = 1011
const keyF2*         = 1012
const keyF3*         = 1013
const keyF4*         = 1014
const keyF5*         = 1015
const keyF6*         = 1016
const keyF7*         = 1017
const keyF8*         = 1018
const keyF9*         = 1019
const keyF10*        = 1020
const keyF11*        = 1021
const keyF12*        = 1022

const XTERM_COLOR    = "xterm-color"
const XTERM_256COLOR = "xterm-256color"


when defined(windows):
  import encodings, unicode, winlean

  proc kbhit(): cint {.importc: "_kbhit", header: "<conio.h>".}
  proc getch(): cint {.importc: "_getch", header: "<conio.h>".}

  proc consoleInit*()   = discard
  proc consoleDeinit*() = discard

  proc getKey*(): int =
    var key = keyNone

    if kbhit() > 0:
      let c = getch()
      case c:
      of   0:
        case getch():
        of 59: key = keyF1
        of 60: key = keyF2
        of 61: key = keyF3
        of 62: key = keyF4
        of 63: key = keyF5
        of 64: key = keyF6
        of 65: key = keyF7
        of 66: key = keyF8
        of 67: key = keyF9
        of 68: key = keyF10
        else: discard getch()  # ignore unknown 2-key keycodes

      of   8: key = keyBackspace
      of   9: key = keyTab
      of  13: key = keyEnter
      of  32: key = keySpace

      of 224:
        case getch():
        of  72: key = keyUp
        of  75: key = keyLeft
        of  77: key = keyRight
        of  80: key = keyDown

        of  71: key = keyHome
        of  82: key = keyInsert
        of  83: key = keyDelete
        of  79: key = keyEnd
        of  73: key = keyPageUp
        of  81: key = keyPageDown

        of 133: key = keyF11
        of 134: key = keyF12
        else: discard  # ignore unknown 2-key keycodes

      else:
        key = c

    result = key


  proc writeConsole(hConsoleOutput: HANDLE, lpBuffer: pointer,
                    nNumberOfCharsToWrite: DWORD,
                    lpNumberOfCharsWritten: ptr DWORD,
                    lpReserved: pointer): WINBOOL {.
    stdcall, dynlib: "kernel32", importc: "WriteConsoleW".}

  var hStdout = getStdHandle(STD_OUTPUT_HANDLE)
  var utf16LEConverter = open(destEncoding = "utf-16", srcEncoding = "UTF-8")

  proc put*(s: string) =
    var us = utf16LEConverter.convert(s)
    var numWritten: DWORD
    discard writeConsole(hStdout, pointer(us[0].addr), DWORD(s.runeLen),
                         numWritten.addr, nil)


else:  # OSX & Linux
  import posix, tables, termios

  proc nonblock(enabled: bool) =
    var ttyState: Termios

    # get the terminal state
    discard tcGetAttr(STDIN_FILENO, ttyState.addr)

    if enabled:
      # turn off canonical mode & echo
      ttyState.c_lflag = ttyState.c_lflag and not Cflag(ICANON or ECHO)

      # minimum of number input read
      ttyState.c_cc[VMIN] = 0.cuchar

    else:
      # turn on canonical mode & echo
      ttyState.c_lflag = ttyState.c_lflag or ICANON or ECHO

    # set the terminal attributes.
    discard tcSetAttr(STDIN_FILENO, TCSANOW, ttyState.addr)


  proc kbhit(): cint =
    var tv: Timeval
    # TODO Nim 0.18.1: tv.tv_sec = Time(0)
    tv.tv_sec = 0
    tv.tv_usec = 0

    var fds: TFdSet
    FD_ZERO(fds)
    FD_SET(STDIN_FILENO, fds)
    discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)
    return FD_ISSET(STDIN_FILENO, fds)


  proc consoleInit*() =
    nonblock(true)

  proc consoleDeinit*() =
    nonblock(false)

  # surely a 100 char buffer is more than enough; the longest
  # keycode sequence I've seen was 6 chars
  const KEY_SEQUENCE_MAXLEN = 100

  # global keycode buffer
  var keyBuf: array[KEY_SEQUENCE_MAXLEN, int]

  let
    keySequences = {
      keyUp:        @["\eOA", "\e[A"],
      keyDown:      @["\eOB", "\e[B"],
      keyRight:     @["\eOC", "\e[C"],
      keyLeft:      @["\eOD", "\e[D"],

      keyHome:      @["\e[1~", "\e[7~", "\eOH", "\e[H"],
      keyInsert:    @["\e[2~"],
      keyDelete:    @["\e[3~"],
      keyEnd:       @["\e[4~", "\e[8~", "\eOF", "\e[F"],
      keyPageUp:    @["\e[5~"],
      keyPageDown:  @["\e[6~"],

      keyF1:        @["\e[11~", "\eOP"],
      keyF2:        @["\e[12~", "\eOQ"],
      keyF3:        @["\e[13~", "\eOR"],
      keyF4:        @["\e[14~", "\eOS"],
      keyF5:        @["\e[15~"],
      keyF6:        @["\e[17~"],
      keyF7:        @["\e[18~"],
      keyF8:        @["\e[19~"],
      keyF9:        @["\e[20~"],
      keyF10:       @["\e[21~"],
      keyF11:       @["\e[23~"],
      keyF12:       @["\e[24~"]
    }.toTable

  proc parseKey(charsRead: int): int =
    # Inspired by
    # https://github.com/mcandre/charm/blob/master/lib/charm.c
    var key = keyNone

    if charsRead == 1:
      case keyBuf[0]:
      of   9: key = keyTab
      of  10: key = keyEnter
      of  27: key = keyEscape
      of  32: key = keySpace
      of 127: key = keyBackspace
      of 0, 29, 30, 31: discard   # these have no Windows equivalents so
                                  # we'll ignore them
      else:
        key = keyBuf[0]

    else:
      var inputSeq = ""
      for i in 0..<charsRead:
        inputSeq &= char(keyBuf[i])

      for k, sequences in keySequences.pairs:
        for s in sequences:
          if s == inputSeq:
            key = k

    result = key


  proc getKey*(): int =
    var i = 0
    while kbhit() > 0 and i < KEY_SEQUENCE_MAXLEN:
      var ret = read(0, keyBuf[i].addr, 1)
      if ret > 0:
        i += 1
      else:
        break

    if i == 0:  # nothing read
      result = keyNone
    else:
      result = parseKey(i)


  template put*(s: string) = stdout.write s


proc enterFullscreen*() =
  when defined(posix):
    case getEnv("TERM"):
    of XTERM_COLOR:
      stdout.write "\e7\e[?47h"
    of XTERM_256COLOR:
      stdout.write "\e[?1049h"
    else:
      eraseScreen()
  else:
    eraseScreen()

proc exitFullscreen*() =
  when defined(posix):
    case getEnv("TERM"):
    of XTERM_COLOR:
      stdout.write "\e[2J\e[?47l\e8"
    of XTERM_256COLOR:
      stdout.write "\e[?1049l"
    else:
      eraseScreen()
  else:
    eraseScreen()

type GraphicsChars* = object
  boxHoriz*:     string
  boxHorizUp*:   string
  boxHorizDown*: string
  boxVert*:      string
  boxVertLeft*:  string
  boxVertRight*: string
  boxVertHoriz*: string
  boxUpRight*:   string
  boxUpLeft*:    string
  boxDownLeft*:  string
  boxDownRight*: string
  fullBlock*:    string
  darkShade*:    string
  mediumShade*:  string
  lightShade*:   string

let gfxCharsUnicode* = GraphicsChars(
  boxHoriz:     "─",
  boxHorizUp:   "┴",
  boxHorizDown: "┬",
  boxVert:      "│",
  boxVertLeft:  "┤",
  boxVertRight: "├",
  boxVertHoriz: "┼",
  boxUpRight:   "└",
  boxUpLeft:    "┘",
  boxDownLeft:  "┐",
  boxDownRight: "┌",
  fullBlock:    "█",
  darkShade:    "▓",
  mediumShade:  "▒",
  lightShade:   "░"
)

let gfxCharsAscii* = GraphicsChars(
  boxHoriz:     "-",
  boxHorizUp:   "+",
  boxHorizDown: "+",
  boxVert:      "|",
  boxVertLeft:  "+",
  boxVertRight: "+",
  boxVertHoriz: "+",
  boxUpRight:   "+",
  boxUpLeft:    "+",
  boxDownLeft:  "+",
  boxDownRight: "+",
  fullBlock:    "#",
  darkShade:    "#",
  mediumShade:  " ",
  lightShade:   " "
)

#[
when defined(posix):
  # TODO doesn't work... why?
  onSignal(SIGTSTP):
    signal(SIGTSTP, SIG_DFL)
    exitFullscreen()
    resetAttributes()
    consoleDeinit()
    showCursor()
    discard `raise`(SIGTSTP)

  onSignal(SIGCONT):
    enterFullscreen()
    consoleInit()
    hideCursor()

  var SIGWINCH* {.importc, header: "<signal.h>".}: cint

  onSignal(SIGWINCH):
    quit(1)
]#

type
  Char* = object
    ch*: Rune
    fg*: ForegroundColor
    bg*: BackgroundColor
    style*: set[Style]

  ConsoleBuffer* = ref object
    width: int
    height: int
    buf: seq[Char]
    currBg: BackgroundColor
    currFg: ForegroundColor
    currStyle: set[Style]
    currX: Natural
    currY: Natural

proc `[]=`*(cb: var ConsoleBuffer, x, y: Natural, ch: Char) =
  if x < cb.width and y < cb.height:
    cb.buf[cb.width * y + x] = ch

proc `[]`*(cb: ConsoleBuffer, x, y: Natural): Char =
  if x < cb.width and y < cb.height:
    result = cb.buf[cb.width * y + x]

proc clear*(cb: var ConsoleBuffer, ch: string = " ") =
  for y in 0..<cb.height:
    for x in 0..<cb.width:
      var c = Char(ch: ch.runeAt(0), fg: cb.currFg, bg: cb.currBg,
                   style: cb.currStyle)
      cb[x,y] = c

proc newConsoleBuffer*(width, height: Natural): ConsoleBuffer =
  var cb = new ConsoleBuffer
  cb.width = width
  cb.height = height
  newSeq(cb.buf, width * height)
  cb.currBg = bgBlack
  cb.currFg = fgWhite
  cb.currStyle = {}
  cb.clear()
  result = cb

proc width*(cb: ConsoleBuffer): Natural =
  result = cb.width

proc height*(cb: ConsoleBuffer): Natural =
  result = cb.height

proc setBackgroundColor*(cb: var ConsoleBuffer, bg: BackgroundColor) =
  cb.currBg = bg

proc setForegroundColor*(cb: var ConsoleBuffer, fg: ForegroundColor) =
  cb.currFg = fg

proc setStyle*(cb: var ConsoleBuffer, style: set[Style]) =
  cb.currStyle = style

proc getBackgroundColor*(cb: var ConsoleBuffer): BackgroundColor =
  result = cb.currBg

proc getForegroundColor*(cb: var ConsoleBuffer): ForegroundColor =
  result = cb.currFg

proc getStyle*(cb: var ConsoleBuffer): set[Style] =
  result = cb.currStyle

proc write*(cb: var ConsoleBuffer, x, y: Natural, s: string) =
  var currX = x
  for ch in runes(s):
    var c = Char(ch: ch, fg: cb.currFg, bg: cb.currBg, style: cb.currStyle)
    cb[currX, y] = c
    inc(currX)
  cb.currX = currX
  cb.currY = y

proc write*(cb: var ConsoleBuffer, s: string) =
  write(cb, cb.currX, cb.currY, s)

proc setChar*(cb: var ConsoleBuffer, x, y: Natural, ch: string) =
  var c = cb[x,y]
  c.ch = ch.runeAt(0)
  cb[x,y] = c

proc setStyle*(cb: var ConsoleBuffer, x, y: Natural, s: set[Style]) =
  var c = cb[x,y]
  c.style = s
  cb[x,y] = c

proc setBackgroundColor*(cb: var ConsoleBuffer, x, y: Natural,
                         bg: BackgroundColor) =
  var c = cb[x,y]
  c.bg = bg
  cb[x,y] = c

proc setForegroundColor*(cb: var ConsoleBuffer, x, y: Natural,
                         fg: ForegroundColor) =
  var c = cb[x,y]
  c.fg = fg
  cb[x,y] = c

proc getChar*(cb: var ConsoleBuffer, x, y: Natural): Rune =
  result = cb[x,y].ch

proc getStyle*(cb: var ConsoleBuffer, x, y: Natural): set[Style] =
  result = cb[x,y].style

proc getBackgroundColor*(cb: var ConsoleBuffer,
                         x, y: Natural): BackgroundColor =
  result = cb[x,y].bg

proc getForegroundColor*(cb: var ConsoleBuffer,
                         x, y: Natural): ForegroundColor =
  result = cb[x,y].fg



var gPrevConsoleBuffer: ConsoleBuffer

proc displayAll*(cb: ConsoleBuffer) =
  var
    currBg: BackgroundColor
    currFg: ForegroundColor
    currStyle: set[Style]

  var strBuf = ""

  proc flushStrBuf =
    if strBuf.len > 0:
      put strBuf
      strBuf = ""

  resetAttributes()
  for y in 0..<cb.height:
    # TODO Nim 0.18.1: remove +1 hack
    setCursorPos(0, y+1)
    for x in 0..<cb.width:
      let c = cb[x,y]
#      if c.bg != currBg:
#        flushStrBuf()
#        currBg = c.bg
#        setBackgroundColor(currBg)
      if c.fg != currFg:
        flushStrBuf()
        currFg = c.fg
        setForegroundColor(currFg)
      if c.style != currStyle:
        flushStrBuf()
        currStyle = c.style
        setStyle(currStyle)
      strBuf = strBuf & $cb[x,y].ch
    flushStrBuf()


proc displayDiff*(cb: ConsoleBuffer) =
  var
    currBg: BackgroundColor
    currFg: ForegroundColor
    currStyle: set[Style]

  var
    buf = ""
    x, y, bufx: Natural

  proc flush() =
    if buf.len > 0:
      # TODO Nim 0.18.1: remove +1 hack
      setCursorXPos(bufx+1)
      put buf
      buf = ""

  resetAttributes()
  for y in 0..<cb.height:
    # TODO Nim 0.18.1: remove +1 hack
    setCursorPos(0, y+1)
    bufx = 0
    for x in 0..<cb.width:
      let c = cb[x,y]
      if c != gPrevConsoleBuffer[x,y]:
        if c.fg != currFg:
          flush()
          bufx = x
          currFg = c.fg
          setForegroundColor(currFg)
        if c.style != currStyle:
          flush()
          bufx = x
          currStyle = c.style
          setStyle(currStyle)
        buf = buf & $cb[x,y].ch
      else:
        flush()
        bufx = x+1
    flush()


proc display*(cb: ConsoleBuffer) =
  if gPrevConsoleBuffer == nil:
    displayAll(cb)
    gPrevConsoleBuffer = cb
  else:
    if cb.width == gPrevConsoleBuffer.width and
       cb.height == gPrevConsoleBuffer.height:
      displayDiff(cb)
      gPrevConsoleBuffer = cb
    else:
      displayAll(cb)
      gPrevConsoleBuffer = cb
  flushFile(stdout)

type
  BoxChar = object
    horiz:      BoxHoriz
    vert:       BoxVert
    horizStyle: LineStyle
    vertStyle:  LineStyle

  BoxHoriz = enum
    bhNone, bhHoriz, bhLeft, bhRight

  BoxVert = enum
    bvNone, bvVert, bvUp, bvDown

  LineStyle = enum
    lsSingle, lsDouble

proc isEmpty(c: BoxChar): bool =
  result = c.horiz == bhNone and c.vert == bvNone


proc toString*(c: BoxChar): string =
  case c.horiz
  of bhNone:
    case c.vertStyle
    of lsSingle:
      case c.vert
      of bvNone: result = " "
      of bvVert: result = "│"
      of bvUp:   result = "│"
      of bvDown: result = "│"
    of lsDouble:
      case c.vert
      of bvNone: result = " "
      of bvVert: result = "║"
      of bvUp:   result = "║"
      of bvDown: result = "║"

  of bhHoriz:
    case c.horizStyle
    of lsSingle:
      case c.vertStyle
      of lsSingle:
        case c.vert
        of bvNone: result = "─"
        of bvVert: result = "┼"
        of bvUp:   result = "┴"
        of bvDown: result = "┬"
      of lsDouble:
        case c.vert
        of bvNone: result = "─"
        of bvVert: result = "╫"
        of bvUp:   result = "╨"
        of bvDown: result = "╥"
    of lsDouble:
      case c.vertStyle:
      of lsSingle:
        case c.vert
        of bvNone: result = "═"
        of bvVert: result = "╪"
        of bvUp:   result = "╧"
        of bvDown: result = "╤"
      of lsDouble:
        case c.vert
        of bvNone: result = "═"
        of bvVert: result = "╬"
        of bvUp:   result = "╩"
        of bvDown: result = "╦"

  of bhLeft:
    case c.horizStyle
    of lsSingle:
      case c.vertStyle
      of lsSingle:
        case c.vert
        of bvNone: result = "─"
        of bvVert: result = "┤"
        of bvUp:   result = "┘"
        of bvDown: result = "┐"
      of lsDouble:
        case c.vert
        of bvNone: result = "─"
        of bvVert: result = "╢"
        of bvUp:   result = "╜"
        of bvDown: result = "╖"
    of lsDouble:
      case c.vertStyle
      of lsSingle:
        case c.vert
        of bvNone: result = "═"
        of bvVert: result = "╡"
        of bvUp:   result = "╛"
        of bvDown: result = "╕"
      of lsDouble:
        case c.vert
        of bvNone: result = "═"
        of bvVert: result = "╣"
        of bvUp:   result = "╝"
        of bvDown: result = "╗"

  of bhRight:
    case c.horizStyle
    of lsSingle:
      case c.vertStyle
      of lsSingle:
        case c.vert
        of bvNone: result = "─"
        of bvVert: result = "├"
        of bvUp:   result = "└"
        of bvDown: result = "┌"
      of lsDouble:
        case c.vert
        of bvNone: result = "─"
        of bvVert: result = "╟"
        of bvUp:   result = "╙"
        of bvDown: result = "╓"
    of lsDouble:
      case c.vertStyle
      of lsSingle:
        case c.vert
        of bvNone: result = "═"
        of bvVert: result = "╞"
        of bvUp:   result = "╘"
        of bvDown: result = "╒"
      of lsDouble:
        case c.vert
        of bvNone: result = "═"
        of bvVert: result = "╠"
        of bvUp:   result = "╚"
        of bvDown: result = "╔"


type BoxBuffer* = ref object
  width: Natural
  height: Natural
  buf: seq[BoxChar]

proc newBoxBuffer*(width, height: Natural): BoxBuffer =
  result = new BoxBuffer
  result.width = width
  result.height = height
  newSeq(result.buf, width * height)

proc `[]=`*(b: var BoxBuffer, x, y: Natural, c: BoxChar) =
  if x < b.width and y < b.height:
    b.buf[b.width * y + x] = c

proc `[]`*(b: BoxBuffer, x, y: Natural): BoxChar =
  if x < b.width and y < b.height:
    result = b.buf[b.width * y + x]

proc drawHorizLine*(b: var BoxBuffer, x1, x2, y: Natural,
                    style: LineStyle = lsSingle) =
  if y < b.height:
    var xStart = x1
    var xEnd = x2
    if xStart > xEnd: swap(xStart, xEnd)
    if xStart < b.width:
      xEnd = min(xEnd, b.width-1)
      for x in xStart..xEnd:
        let pos = y * b.width + x
        var c = b.buf[pos]
        if x == xStart:
          c.horiz = if c.horiz == bhLeft: bhHoriz else: bhRight
        elif x == xEnd:
          c.horiz = if c.horiz == bhRight: bhHoriz else: bhLeft
        else:
          c.horiz = bhHoriz
        c.horizStyle = style
        b.buf[pos] = c

proc drawVertLine*(b: var BoxBuffer, x, y1, y2: Natural,
                  style: LineStyle = lsSingle) =
  if x < b.width:
    var yStart = y1
    var yEnd = y2
    if yStart > yEnd: swap(yStart, yEnd)
    if yStart < b.height:
      yEnd = min(yEnd, b.height-1)
      for y in yStart..yEnd:
        let pos = y * b.width + x
        var c = b.buf[pos]
        if y == yStart:
          c.vert = if c.vert == bvUp: bvVert else: bvDown
        elif y == yEnd:
          c.vert = if c.vert == bvDown: bvVert else: bvUp
        else:
          c.vert = bvVert
        c.vertStyle = style
        b.buf[pos] = c

proc write*(cb: var ConsoleBuffer, b: BoxBuffer) =
  let width = min(cb.width, b.width)
  let height = min(cb.height, b.height)
  for y in 0..<height:
    for x in 0..<width:
      let boxChar = b.buf[y * b.width + x]
      if not boxChar.isEmpty:
        var c = Char(ch: (boxChar.toString).runeAt(0),
                     fg: cb.currFg, bg: cb.currBg, style: cb.currStyle)
        cb[x,y] = c


proc cleanExit() {.noconv.} =
  consoleDeinit()
  exitFullscreen()
  showCursor()
  resetAttributes()
  quit(0)

setControlCHook(cleanExit)

# "•‹«»›←↑→↓↔↕≡▀▄█▌▐■▲►▼◄"
# TODO test code, remove
when isMainModule:
  consoleInit()
  enterFullscreen()
  hideCursor()
  resetAttributes()

  var x: Natural = 0

  while true:
    case getKey()
    of ord('h'): x = max(0, x-1)
    of ord('l'): inc(x)

    of keyEscape, ord('q'):
      cleanExit()

    else: discard

    var cb = newConsoleBuffer(80, 40)
#    cb.write(x, 0, "yikes!")
    cb.write(x+0, 1, "1 2")
#    cb.setForegroundColor(fgRed)
#    cb.write(x+2, 2, "NOW SOMETHING IN RED")
#    cb.setStyle({styleBright})
#    cb.write(x+3, 3, "bright red")
#
#    var bb = newBoxBuffer(cb.width, cb.height)
#    bb.drawHorizLine(5, 20, 6)
#    bb.drawHorizLine(5, 20, 9)
#    bb.drawHorizLine(5, 20, 14, style = lsDouble)
#    bb.drawVertLine(3, 6, 14)
#    bb.drawVertLine(5, 6, 14)
#    bb.drawVertLine(8, 5, 14, style = lsDouble)
#    bb.drawVertLine(3, 6, 14)
#    bb.drawVertLine(5, 6, 14)
#    bb.drawVertLine(8, 5, 14, style = lsDouble)
#    bb.drawVertLine(20, 6, 14, style = lsSingle)
#    cb.write(bb)

    cb.display()

    sleep(400)

    var cb2 = newConsoleBuffer(80, 40)
#    cb2.write(x, 0, "yikes!")
    cb2.write(x+0, 1, "1 N 2")
#    cb2.setForegroundColor(fgRed)
#    cb2.write(x+2, 2, "NOW what SOMETHING IN RED")
#    cb2.setStyle({styleBright})
#    cb2.write(x+3, 3, "bright red")

    cb2.display()

    sleep(1000)

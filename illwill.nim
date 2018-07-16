## Module documentation *TODO* ``code``
##
## Example:
##
## .. code-block:: nim
##
##   proc error(msg: string) =
##     styledWriteLine(stderr, fgRed, "Error: ", resetStyle, msg)
##

import os, strformat, terminal, unicode

export terminal.terminalWidth
export terminal.terminalHeight
export terminal.terminalSize
export terminal.hideCursor
export terminal.showCursor
export terminal.Style

type
  ForegroundColor* = enum   ## Foreground colors
    fgNone = 0,             ## default
    fgBlack = 30,           ## black
    fgRed,                  ## red
    fgGreen,                ## green
    fgYellow,               ## yellow
    fgBlue,                 ## blue
    fgMagenta,              ## magenta
    fgCyan,                 ## cyan
    fgWhite                 ## white

  BackgroundColor* = enum   ## Background colors
    bgNone = 0,             ## default (transparent)
    bgBlack = 40,           ## black
    bgRed,                  ## red
    bgGreen,                ## green
    bgYellow,               ## yellow
    bgBlue,                 ## blue
    bgMagenta,              ## magenta
    bgCyan,                 ## cyan
    bgWhite                 ## white

  Key* {.pure.} = enum
    None = (-1, "None"),

    # Special ASCII characters
    CtrlA  = (1, "CtrlA"),
    CtrlB  = (2, "CtrlB"),
    CtrlC  = (3, "CtrlC"),
    CtrlD  = (4, "CtrlD"),
    CtrlE  = (5, "CtrlE"),
    CtrlF  = (6, "CtrlF"),
    CtrlG  = (7, "CtrlG"),
    CtrlH  = (8, "CtrlH"),
    Tab    = (9, "Tab"),     # Ctrl-I
    CtrlJ  = (10, "CtrlJ"),
    CtrlK  = (11, "CtrlK"),
    CtrlL  = (12, "CtrlL"),
    Enter  = (13, "Enter"),  # Ctrl-M
    CtrlN  = (14, "CtrlN"),
    CtrlO  = (15, "CtrlO"),
    CtrlP  = (16, "CtrlP"),
    CtrlQ  = (17, "CtrlQ"),
    CtrlR  = (18, "CtrlR"),
    CtrlS  = (19, "CtrlS"),
    CtrlT  = (20, "CtrlT"),
    CtrlU  = (21, "CtrlU"),
    CtrlV  = (22, "CtrlV"),
    CtrlW  = (23, "CtrlW"),
    CtrlX  = (24, "CtrlX"),
    CtrlY  = (25, "CtrlY"),
    CtrlZ  = (26, "CtrlZ"),
    Escape = (27, "Escape"),

    CtrlBackslash    = (28, "CtrlBackslash"),
    CtrlRightBracket = (29, "CtrlRightBracket"),

    # Printable ASCII characters
    Space           = (32, "Space"),
    ExclamationMark = (33, "ExclamationMark"),
    DoubleQuote     = (34, "DoubleQuote"),
    Hash            = (35, "Hash"),
    Dollar          = (36, "Dollar"),
    Percent         = (37, "Percent"),
    Ampersand       = (38, "Ampersand"),
    SingleQuote     = (39, "SingleQuote"),
    LeftParen       = (40, "LeftParen"),
    RightParen      = (41, "RightParen"),
    Asterisk        = (42, "Asterisk"),
    Plus            = (43, "Plus"),
    Comma           = (44, "Comma"),
    Minus           = (45, "Minus"),
    Dot             = (46, "Dot"),
    Slash           = (47, "Slash"),

    Zero  = (48, "Zero"),
    One   = (49, "One"),
    Two   = (50, "Two"),
    Three = (51, "Three"),
    Four  = (52, "Four"),
    Five  = (53, "Five"),
    Six   = (54, "Six"),
    Seven = (55, "Seven"),
    Eight = (56, "Eight"),
    Nine  = (57, "Nine"),

    Colon        = (58, "Colon"),
    Semicolon    = (59, "Semicolon"),
    LessThan     = (60, "LessThan"),
    Equals       = (61, "Equals"),
    GreaterThan  = (62, "GreaterThan"),
    QuestionMark = (63, "QuestionMark"),
    At           = (64, "At"),

    ShiftA  = (65, "ShiftA"),
    ShiftB  = (66, "ShiftB"),
    ShiftC  = (67, "ShiftC"),
    ShiftD  = (68, "ShiftD"),
    ShiftE  = (69, "ShiftE"),
    ShiftF  = (70, "ShiftF"),
    ShiftG  = (71, "ShiftG"),
    ShiftH  = (72, "ShiftH"),
    ShiftI  = (73, "ShiftI"),
    ShiftJ  = (74, "ShiftJ"),
    ShiftK  = (75, "ShiftK"),
    ShiftL  = (76, "ShiftL"),
    ShiftM  = (77, "ShiftM"),
    ShiftN  = (78, "ShiftN"),
    ShiftO  = (79, "ShiftO"),
    ShiftP  = (80, "ShiftP"),
    ShiftQ  = (81, "ShiftQ"),
    ShiftR  = (82, "ShiftR"),
    ShiftS  = (83, "ShiftS"),
    ShiftT  = (84, "ShiftT"),
    ShiftU  = (85, "ShiftU"),
    ShiftV  = (86, "ShiftV"),
    ShiftW  = (87, "ShiftW"),
    ShiftX  = (88, "ShiftX"),
    ShiftY  = (89, "ShiftY"),
    ShiftZ  = (90, "ShiftZ"),

    LeftBracket  = (91, "LeftBracket"),
    Backslash    = (92, "Backslash"),
    RightBracket = (93, "RightBracket"),
    Caret        = (94, "Caret"),
    Underscore   = (95, "Underscore"),
    GraveAccent  = (96, "GraveAccent"),

    A = (97, "A"),
    B = (98, "B"),
    C = (99, "C"),
    D = (100, "D"),
    E = (101, "E"),
    F = (102, "F"),
    G = (103, "G"),
    H = (104, "H"),
    I = (105, "I"),
    J = (106, "J"),
    K = (107, "K"),
    L = (108, "L"),
    M = (109, "M"),
    N = (110, "N"),
    O = (111, "O"),
    P = (112, "P"),
    Q = (113, "Q"),
    R = (114, "R"),
    S = (115, "S"),
    T = (116, "T"),
    U = (117, "U"),
    V = (118, "V"),
    W = (119, "W"),
    X = (120, "X"),
    Y = (121, "Y"),
    Z = (122, "Z"),

    LeftBrace  = (123, "LeftBrace"),
    Pipe       = (124, "Pipe"),
    RightBrace = (125, "RightBrace"),
    Tilde      = (126, "Tilde"),
    Backspace  = (127, "Backspace"),

    # Special characters with virtual keycodes
    Up       = (1001, "Up"),
    Down     = (1002, "Down"),
    Right    = (1003, "Right"),
    Left     = (1004, "Left"),
    Home     = (1005, "Home"),
    Insert   = (1006, "Insert"),
    Delete   = (1007, "Delete"),
    End      = (1008, "End"),
    PageUp   = (1009, "PageUp"),
    PageDown = (1010, "PageDown"),

    F1  = (1011, "F1"),
    F2  = (1012, "F2"),
    F3  = (1013, "F3"),
    F4  = (1014, "F4"),
    F5  = (1015, "F5"),
    F6  = (1016, "F6"),
    F7  = (1017, "F7"),
    F8  = (1018, "F8"),
    F9  = (1019, "F9"),
    F10 = (1020, "F10"),
    F11 = (1021, "F11"),
    F12 = (1022, "F12")


proc toKey(c: int): Key =
  try:
    result = Key(c)
  except RangeError:  # ignore unknown keycodes
    result = Key.None


template isNimPre0_18_1: bool =
  NimMajor <= 0 and NimMinor <= 18 and NimPatch <= 0


when defined(windows):
  import encodings, unicode, winlean

  proc kbhit(): cint {.importc: "_kbhit", header: "<conio.h>".}
  proc getch(): cint {.importc: "_getch", header: "<conio.h>".}

  proc consoleInit*() =
    resetAttributes()

  proc consoleDeinit*() =
    resetAttributes()

  proc getKey*(): Key =
    var key = Key.None

    if kbhit() > 0:
      let c = getch()
      case c:
      of   0:
        case getch():
        of 59: key = Key.F1
        of 60: key = Key.F2
        of 61: key = Key.F3
        of 62: key = Key.F4
        of 63: key = Key.F5
        of 64: key = Key.F6
        of 65: key = Key.F7
        of 66: key = Key.F8
        of 67: key = Key.F9
        of 68: key = Key.F10
        else: discard getch()  # ignore unknown 2-key keycodes

      of   8: key = Key.Backspace
      of   9: key = Key.Tab
      of  13: key = Key.Enter
      of  32: key = Key.Space

      of 224:
        case getch():
        of  72: key = Key.Up
        of  75: key = Key.Left
        of  77: key = Key.Right
        of  80: key = Key.Down

        of  71: key = Key.Home
        of  82: key = Key.Insert
        of  83: key = Key.Delete
        of  79: key = Key.End
        of  73: key = Key.PageUp
        of  81: key = Key.PageDown

        of 133: key = Key.F11
        of 134: key = Key.F12
        else: discard  # ignore unknown 2-key keycodes

      else:
        key = toKey(c)

    result = key


  proc writeConsole(hConsoleOutput: HANDLE, lpBuffer: pointer,
                    nNumberOfCharsToWrite: DWORD,
                    lpNumberOfCharsWritten: ptr DWORD,
                    lpReserved: pointer): WINBOOL {.
    stdcall, dynlib: "kernel32", importc: "WriteConsoleW".}

  var hStdout = getStdHandle(STD_OUTPUT_HANDLE)
  var utf16LEConverter = open(destEncoding = "utf-16", srcEncoding = "UTF-8")

  proc put(s: string) =
    var us = utf16LEConverter.convert(s)
    var numWritten: DWORD
    discard writeConsole(hStdout, pointer(us[0].addr), DWORD(s.runeLen),
                         numWritten.addr, nil)


else:  # OS X & Linux
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
    when isNimPre0_18_1:
      tv.tv_sec = 0
    else:
      tv.tv_sec = Time(0)
    tv.tv_usec = 0

    var fds: TFdSet
    FD_ZERO(fds)
    FD_SET(STDIN_FILENO, fds)
    discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)
    return FD_ISSET(STDIN_FILENO, fds)


  proc consoleInit*() =
    resetAttributes()
    nonblock(true)

  proc consoleDeinit*() =
    resetAttributes()
    nonblock(false)

  # surely a 100 char buffer is more than enough; the longest
  # keycode sequence I've seen was 6 chars
  const KEY_SEQUENCE_MAXLEN = 100

  # global keycode buffer
  var keyBuf: array[KEY_SEQUENCE_MAXLEN, int]

  let
    keySequences = {
      ord(Key.Up):        @["\eOA", "\e[A"],
      ord(Key.Down):      @["\eOB", "\e[B"],
      ord(Key.Right):     @["\eOC", "\e[C"],
      ord(Key.Left):      @["\eOD", "\e[D"],

      ord(Key.Home):      @["\e[1~", "\e[7~", "\eOH", "\e[H"],
      ord(Key.Insert):    @["\e[2~"],
      ord(Key.Delete):    @["\e[3~"],
      ord(Key.End):       @["\e[4~", "\e[8~", "\eOF", "\e[F"],
      ord(Key.PageUp):    @["\e[5~"],
      ord(Key.PageDown):  @["\e[6~"],

      ord(Key.F1):        @["\e[11~", "\eOP"],
      ord(Key.F2):        @["\e[12~", "\eOQ"],
      ord(Key.F3):        @["\e[13~", "\eOR"],
      ord(Key.F4):        @["\e[14~", "\eOS"],
      ord(Key.F5):        @["\e[15~"],
      ord(Key.F6):        @["\e[17~"],
      ord(Key.F7):        @["\e[18~"],
      ord(Key.F8):        @["\e[19~"],
      ord(Key.F9):        @["\e[20~"],
      ord(Key.F10):       @["\e[21~"],
      ord(Key.F11):       @["\e[23~"],
      ord(Key.F12):       @["\e[24~"]
    }.toTable

  proc parseKey(charsRead: int): Key =
    # Inspired by
    # https://github.com/mcandre/charm/blob/master/lib/charm.c
    var key = Key.None
    if charsRead == 1:
      let ch = keyBuf[0]
      case ch:
      of   9: key = Key.Tab
      of  10: key = Key.Enter
      of  27: key = Key.Escape
      of  32: key = Key.Space
      of 127: key = Key.Backspace
      of 0, 29, 30, 31: discard   # these have no Windows equivalents so
                                  # we'll ignore them
      else:
        key = toKey(ch)
    else:
      var inputSeq = ""
      for i in 0..<charsRead:
        inputSeq &= char(keyBuf[i])
      for keyCode, sequences in keySequences.pairs:
        for s in sequences:
          if s == inputSeq:
            key = toKey(keyCode)
    result = key

  proc getKey*(): Key =
    var i = 0
    while kbhit() > 0 and i < KEY_SEQUENCE_MAXLEN:
      var ret = read(0, keyBuf[i].addr, 1)
      if ret > 0:
        i += 1
      else:
        break
    if i == 0:  # nothing read
      result = Key.None
    else:
      result = parseKey(i)

  template put(s: string) = stdout.write s


const
  XTERM_COLOR    = "xterm-color"
  XTERM_256COLOR = "xterm-256color"

proc enterFullscreen*() =
  ## stuff
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


# TODO remove, convert?
#[
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
]#

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
  ConsoleChar* = object
    ch*: Rune
    fg*: ForegroundColor
    bg*: BackgroundColor
    style*: set[Style]

  ConsoleBuffer* = ref object
    width: int
    height: int
    buf: seq[ConsoleChar]
    currBg: BackgroundColor
    currFg: ForegroundColor
    currStyle: set[Style]
    currX: Natural
    currY: Natural

proc `[]=`*(cb: var ConsoleBuffer, x, y: Natural, ch: ConsoleChar) =
  if x < cb.width and y < cb.height:
    cb.buf[cb.width * y + x] = ch

proc `[]`*(cb: ConsoleBuffer, x, y: Natural): ConsoleChar =
  if x < cb.width and y < cb.height:
    result = cb.buf[cb.width * y + x]

proc clear*(cb: var ConsoleBuffer, ch: string = " ",
            fg: ForegroundColor = fgNone, bg: BackgroundColor = bgNone,
            style: set[Style] = {}) =
  let c = ConsoleChar(ch: ch.runeAt(0), fg: fg, bg: bg, style: style)
  for y in 0..<cb.height:
    for x in 0..<cb.width:
      cb[x,y] = c

proc initConsoleBuffer(cb: var ConsoleBuffer, width, height: Natural) =
  cb.width = width
  cb.height = height
  newSeq(cb.buf, width * height)
  cb.currBg = bgNone
  cb.currFg = fgNone
  cb.currStyle = {}

proc newConsoleBuffer*(width, height: Natural): ConsoleBuffer =
  var cb = new ConsoleBuffer
  cb.initConsoleBuffer(width, height)
  cb.clear()
  result = cb

proc width*(cb: ConsoleBuffer): Natural =
  result = cb.width

proc height*(cb: ConsoleBuffer): Natural =
  result = cb.height

proc copyFrom*(cb: var ConsoleBuffer, src: ConsoleBuffer) =
  let
    w = min(cb.width, src.width)
    h = min(cb.height, src.height)
  for y in 0..<h:
    for x in 0..<w:
      cb[x,y] = src[x,y]

proc newConsoleBufferFrom*(src: ConsoleBuffer): ConsoleBuffer =
  var cb = new ConsoleBuffer
  cb.initConsoleBuffer(src.width, src.height)
  cb.copyFrom(src)
  result = cb

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
    var c = ConsoleChar(ch: ch, fg: cb.currFg, bg: cb.currBg,
                        style: cb.currStyle)
    cb[currX, y] = c
    inc(currX)
  cb.currX = currX
  cb.currY = y

proc write*(cb: var ConsoleBuffer, s: string) =
  write(cb, cb.currX, cb.currY, s)


var
  prevConsoleBuffer: ConsoleBuffer
  currBg: BackgroundColor
  currFg: ForegroundColor
  currStyle: set[Style]

proc setAttribs(c: ConsoleChar) =
  if c.bg == bgNone or c.fg == fgNone or c.style == {}:
    resetAttributes()
    currBg = c.bg
    currFg = c.fg
    currStyle = c.style
    if currBg != bgNone:
      setBackgroundColor(cast[terminal.BackgroundColor](currBg))
    if currFg != fgNone:
      setForegroundColor(cast[terminal.ForegroundColor](currFg))
    if currStyle != {}:
      setStyle(currStyle)
  else:
    if c.bg != currBg:
      currBg = c.bg
      setBackgroundColor(cast[terminal.BackgroundColor](currBg))
    if c.fg != currFg:
      currFg = c.fg
      setForegroundColor(cast[terminal.ForegroundColor](currFg))
    if c.style != currStyle:
      currStyle = c.style
      setStyle(currStyle)

proc setPos(x, y: Natural) =
  when isNimPre0_18_1() and defined(posix):
    setCursorPos(x+1, y+1)
  else:
    setCursorPos(x, y)

proc setXPos(x: Natural) =
  when isNimPre0_18_1() and defined(posix):
    setCursorXPos(x+1)
  else:
    setCursorXPos(x)


proc displayFull(cb: ConsoleBuffer) =
  var buf = ""

  proc flushBuf() =
    if buf.len > 0:
      put buf
      buf = ""

  for y in 0..<cb.height:
    setPos(0, y)
    for x in 0..<cb.width:
      let c = cb[x,y]
      if c.bg != currBg or c.fg != currFg or c.style != currStyle:
        flushBuf()
        setAttribs(c)
      buf &= $c.ch
    flushBuf()


proc displayDiff(cb: ConsoleBuffer) =
  var
    buf = ""
    bufXPos, bufYPos: Natural
    currXPos = -1
    currYPos = -1

  proc flushBuf() =
    if buf.len > 0:
      if currYPos != bufYPos:
        currXPos = bufXPos
        currYPos = bufYPos
        setPos(currXPos, currYPos)
      elif currXPos != bufXPos:
        currXPos = bufXPos
        setXPos(currXPos)
      put buf
      inc(currXPos, buf.runeLen)
      buf = ""

  for y in 0..<cb.height:
    bufXPos = 0
    bufYPos = y
    for x in 0..<cb.width:
      let c = cb[x,y]
      if c != prevConsoleBuffer[x,y]:
        if c.bg != currBg or c.fg != currFg or c.style != currStyle:
          flushBuf()
          bufXPos = x
          setAttribs(c)
        buf &= $c.ch
      else:
        flushBuf()
        bufXPos = x+1
    flushBuf()


var doubleBufferingEnabled = true

proc setDoubleBuffering*(enabled: bool) =
  doubleBufferingEnabled = enabled
  prevConsoleBuffer = nil

proc display*(cb: ConsoleBuffer) =
  if doubleBufferingEnabled:
    if prevConsoleBuffer == nil:
      displayFull(cb)
      prevConsoleBuffer = newConsoleBufferFrom(cb)
    else:
      if cb.width == prevConsoleBuffer.width and
         cb.height == prevConsoleBuffer.height:
        displayDiff(cb)
        prevConsoleBuffer.copyFrom(cb)
      else:
        displayFull(cb)
        prevConsoleBuffer = newConsoleBufferFrom(cb)
    flushFile(stdout)
  else:
    displayFull(cb)
    flushFile(stdout)


type
  BoxChar* = object
    horiz*:      BoxHoriz
    vert*:       BoxVert
    horizStyle*: BoxLineStyle
    vertStyle*:  BoxLineStyle

  BoxHoriz* = enum
    bhNone, bhHoriz, bhLeft, bhRight

  BoxVert* = enum
    bvNone, bvVert, bvUp, bvDown

  BoxLineStyle* = enum
    lsSingle, lsDouble


proc isEmpty(c: BoxChar): bool =
  result = c.horiz == bhNone and c.vert == bvNone

proc toUTF8String*(c: BoxChar): string =
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

proc `[]`*(b: BoxBuffer, x, y: Natural):  BoxChar =
  if x < b.width and y < b.height:
    result = b.buf[b.width * y + x]

proc drawHorizLine*(b: var BoxBuffer, x1, x2, y: Natural,
                    style: BoxLineStyle = lsSingle) =
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
                  style: BoxLineStyle = lsSingle) =
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
        var c = ConsoleChar(ch: (boxChar.toUTF8String).runeAt(0),
                            fg: cb.currFg, bg: cb.currBg, style: cb.currStyle)
        cb[x,y] = c


# TODO
proc cleanExit() {.noconv.} =
  consoleDeinit()
  exitFullscreen()
  showCursor()
  resetAttributes()
  quit(0)

setControlCHook(cleanExit)


# TODO test code, remove
when isMainModule:
  # "•‹«»›←↑→↓↔↕≡▀▄█▌▐■▲►▼◄"

  consoleInit()
#  enterFullscreen()
#  hideCursor()
#  resetAttributes()

#  var x: Natural = 0

  while true:
    var key = getKey()
    case key
    of Key.None: discard
    of Key.Escape, Key.Q:
      cleanExit()
    else:
      echo key

    sleep(20)

#    var cb = newConsoleBuffer(80, 40)
#    cb.write(x, 0, "yikes!")
#    cb.write(x+0, 1, "1 2")
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
#    cb.setForegroundColor(fgWhite)
#    cb.write(x+0, 1, " Songname")
#    cb.setForegroundColor(fgCyan)
#    cb.write(x+10, 1, " Man's mind")

#    cb.display()

#    sleep(500)

#    var cb2 = newConsoleBuffer(80, 40)
#    cb2.write(x, 0, "yikes!")
#    cb2.write(x+0, 1, "1 N 2")
#    cb2.setForegroundColor(fgRed)
#    cb2.write(x+2, 2, "NOW what SOMETHING IN RED")
#    cb2.setStyle({styleBright})
#    cb2.write(x+3, 3, "bright red")
#    cb.setForegroundColor(fgGreen)
#    cb2.write(x+10, 1, "C")
#    cb2.setForegroundColor(fgGreen)
#    cb2.write(x+14, 1, "12")

#    cb2.display()

#    sleep(1000)

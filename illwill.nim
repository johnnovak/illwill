## :Authors: John Novak
##
## This is a *curses* inspired simple terminal library that aims to make
## writing cross-platform text mode applications easier. The main features are:
##
## * Non-blocking keyboard input
## * Support for key combinations and special keys available in the standard
##   Windows Console (`cmd.exe`), most common POSIX terminals, and browsers (when
##   compiled to JavaScript.)
## * Virtual terminal buffers with double-buffering support (only
##   display changes from the previous frame and minimise the number of
##   attribute changes to reduce CPU usage)
## * Simple graphics using UTF-8 box drawing symbols
## * Full-screen support with restoring the contents of the terminal after
##   exit (restoring works only on POSIX)
## * Basic suspend/continue (`SIGTSTP`, `SIGCONT`) support on POSIX
## * Basic mouse support.
##
## When compiled for Windows or POSIX (Linux or MacOS), the module depends on the standard `terminal
## <https://nim-lang.org/docs/terminal.html>`_ module. However, you
## should not use any terminal functions directly, neither should you use
## `echo`, `write` or other similar functions for output. You should **only**
## use the interface provided by the module to interact with the terminal.
##
## When compiled for Javascript (JS), the `echo` command is safe to use but it's
## output is sent to the debug console NOT the psuedo-terminal.
## 
## Types (section 1 of 2)
## ======================
##
## .. code:: nim
##
##     ForegroundColor* = enum
##       fgNone = 0,             ## default
##       fgBlack = 30,           ## black
##       fgRed,                  ## red
##       fgGreen,                ## green
##       fgYellow,               ## yellow
##       fgBlue,                 ## blue
##       fgMagenta,              ## magenta
##       fgCyan,                 ## cyan
##       fgWhite                 ## white
##
##   Foreground colors
##
## .. code:: nim
##
##     BackgroundColor* = enum
##       bgNone = 0,             ## default (transparent)
##       bgBlack = 40,           ## black
##       bgRed,                  ## red
##       bgGreen,                ## green
##       bgYellow,               ## yellow
##       bgBlue,                 ## blue
##       bgMagenta,              ## magenta
##       bgCyan,                 ## cyan
##       bgWhite                 ## white
##
##   Background colors
##
## .. code:: nim
##
##     Style* = enum
##       styleBright = 1,        ## bright text
##       styleDim,               ## dim text
##       styleItalic,            ## italic (or reverse on terminals not supporting)
##       styleUnderscore,        ## underscored text
##       styleBlink,             ## blinking/bold text
##       styleBlinkRapid,        ## rapid blinking/bold text (not widely supported)
##       styleReverse,           ## reverse
##       styleHidden,            ## hidden text
##       styleStrikethrough      ## strikethrough
##
##   Styles of Text
##
## .. code:: nim
##
##     Key* {.pure.} = enum
##       None = (-1, "None"),
##       CtrlA  = (1, "CtrlA"),
##       CtrlB  = (2, "CtrlB"),
##       CtrlC  = (3, "CtrlC"),
##       CtrlD  = (4, "CtrlD"),
##       CtrlE  = (5, "CtrlE"),
##       CtrlF  = (6, "CtrlF"),
##       CtrlG  = (7, "CtrlG"),
##       CtrlH  = (8, "CtrlH"),
##       Tab    = (9, "Tab"),
##       CtrlJ  = (10, "CtrlJ"),
##       CtrlK  = (11, "CtrlK"),
##       CtrlL  = (12, "CtrlL"),
##       Enter  = (13, "Enter"),
##       CtrlN  = (14, "CtrlN"),
##       CtrlO  = (15, "CtrlO"),
##       CtrlP  = (16, "CtrlP"),
##       CtrlQ  = (17, "CtrlQ"),
##       CtrlR  = (18, "CtrlR"),
##       CtrlS  = (19, "CtrlS"),
##       CtrlT  = (20, "CtrlT"),
##       CtrlU  = (21, "CtrlU"),
##       CtrlV  = (22, "CtrlV"),
##       CtrlW  = (23, "CtrlW"),
##       CtrlX  = (24, "CtrlX"),
##       CtrlY  = (25, "CtrlY"),
##       CtrlZ  = (26, "CtrlZ"),
##       Escape = (27, "Escape"),
##       CtrlBackslash    = (28, "CtrlBackslash"),
##       CtrlRightBracket = (29, "CtrlRightBracket"),
##       Space           = (32, "Space"),
##       ExclamationMark = (33, "ExclamationMark"),
##       DoubleQuote     = (34, "DoubleQuote"),
##       Hash            = (35, "Hash"),
##       Dollar          = (36, "Dollar"),
##       Percent         = (37, "Percent"),
##       Ampersand       = (38, "Ampersand"),
##       SingleQuote     = (39, "SingleQuote"),
##       LeftParen       = (40, "LeftParen"),
##       RightParen      = (41, "RightParen"),
##       Asterisk        = (42, "Asterisk"),
##       Plus            = (43, "Plus"),
##       Comma           = (44, "Comma"),
##       Minus           = (45, "Minus"),
##       Dot             = (46, "Dot"),
##       Slash           = (47, "Slash"),
##       Zero  = (48, "Zero"),
##       One   = (49, "One"),
##       Two   = (50, "Two"),
##       Three = (51, "Three"),
##       Four  = (52, "Four"),
##       Five  = (53, "Five"),
##       Six   = (54, "Six"),
##       Seven = (55, "Seven"),
##       Eight = (56, "Eight"),
##       Nine  = (57, "Nine"),
##       Colon        = (58, "Colon"),
##       Semicolon    = (59, "Semicolon"),
##       LessThan     = (60, "LessThan"),
##       Equals       = (61, "Equals"),
##       GreaterThan  = (62, "GreaterThan"),
##       QuestionMark = (63, "QuestionMark"),
##       At           = (64, "At"),
##       ShiftA  = (65, "ShiftA"),
##       ShiftB  = (66, "ShiftB"),
##       ShiftC  = (67, "ShiftC"),
##       ShiftD  = (68, "ShiftD"),
##       ShiftE  = (69, "ShiftE"),
##       ShiftF  = (70, "ShiftF"),
##       ShiftG  = (71, "ShiftG"),
##       ShiftH  = (72, "ShiftH"),
##       ShiftI  = (73, "ShiftI"),
##       ShiftJ  = (74, "ShiftJ"),
##       ShiftK  = (75, "ShiftK"),
##       ShiftL  = (76, "ShiftL"),
##       ShiftM  = (77, "ShiftM"),
##       ShiftN  = (78, "ShiftN"),
##       ShiftO  = (79, "ShiftO"),
##       ShiftP  = (80, "ShiftP"),
##       ShiftQ  = (81, "ShiftQ"),
##       ShiftR  = (82, "ShiftR"),
##       ShiftS  = (83, "ShiftS"),
##       ShiftT  = (84, "ShiftT"),
##       ShiftU  = (85, "ShiftU"),
##       ShiftV  = (86, "ShiftV"),
##       ShiftW  = (87, "ShiftW"),
##       ShiftX  = (88, "ShiftX"),
##       ShiftY  = (89, "ShiftY"),
##       ShiftZ  = (90, "ShiftZ"),
##       LeftBracket  = (91, "LeftBracket"),
##       Backslash    = (92, "Backslash"),
##       RightBracket = (93, "RightBracket"),
##       Caret        = (94, "Caret"),
##       Underscore   = (95, "Underscore"),
##       GraveAccent  = (96, "GraveAccent"),
##       A = (97, "A"),
##       B = (98, "B"),
##       C = (99, "C"),
##       D = (100, "D"),
##       E = (101, "E"),
##       F = (102, "F"),
##       G = (103, "G"),
##       H = (104, "H"),
##       I = (105, "I"),
##       J = (106, "J"),
##       K = (107, "K"),
##       L = (108, "L"),
##       M = (109, "M"),
##       N = (110, "N"),
##       O = (111, "O"),
##       P = (112, "P"),
##       Q = (113, "Q"),
##       R = (114, "R"),
##       S = (115, "S"),
##       T = (116, "T"),
##       U = (117, "U"),
##       V = (118, "V"),
##       W = (119, "W"),
##       X = (120, "X"),
##       Y = (121, "Y"),
##       Z = (122, "Z"),
##       LeftBrace  = (123, "LeftBrace"),
##       Pipe       = (124, "Pipe"),
##       RightBrace = (125, "RightBrace"),
##       Tilde      = (126, "Tilde"),
##       Backspace  = (127, "Backspace"),
##       # Special characters with virtual keycodes
##       Up       = (1001, "Up"),
##       Down     = (1002, "Down"),
##       Right    = (1003, "Right"),
##       Left     = (1004, "Left"),
##       Home     = (1005, "Home"),
##       Insert   = (1006, "Insert"),
##       Delete   = (1007, "Delete"),
##       End      = (1008, "End"),
##       PageUp   = (1009, "PageUp"),
##       PageDown = (1010, "PageDown"),
##       F1  = (1011, "F1"),
##       F2  = (1012, "F2"),
##       F3  = (1013, "F3"),
##       F4  = (1014, "F4"),
##       F5  = (1015, "F5"),
##       F6  = (1016, "F6"),
##       F7  = (1017, "F7"),
##       F8  = (1018, "F8"),
##       F9  = (1019, "F9"),
##       F10 = (1020, "F10"),
##       F11 = (1021, "F11"),
##       F12 = (1022, "F12"),
##       Mouse = (5000, "Mouse")
##
##   Supported single key presses and key combinations
##
## .. code:: nim
##
##     MouseButtonAction* {.pure.} = enum
##       mbaNone, mbaPressed, mbaReleased
##
## .. code:: nim
##
##     MouseInfo* = object
##       x*: int ## x mouse position
##       y*: int ## y mouse position
##       button*: MouseButton ## which button was pressed
##       action*: MouseButtonAction ## if button was released or pressed
##       ctrl*: bool ## was ctrl was down on event
##       shift*: bool ## was shift was down on event
##       scroll*: bool ## if this is a mouse scroll
##       scrollDir*: ScrollDirection
##       move*: bool ## if this a mouse move
##
## .. code:: nim
##
##     MouseButton* {.pure.} = enum
##       mbNone, mbLeft, mbMiddle, mbRight
##
## .. code:: nim
##
##     ScrollDirection* {.pure.} = enum
##       sdNone, sdUp, sdDown
##
## .. code:: nim
##
##     TerminalChar* = object
##       ch*: Rune
##       fg*: ForegroundColor
##       bg*: BackgroundColor
##       style*: set[Style]
##       forceWrite*: bool
##
##   Represents a character in the terminal buffer, including color and
##   style information.
##
##   If `forceWrite` is set to `true`, the character is always output even
##   when double buffering is enabled (this is a hack to achieve better
##   continuity of horizontal lines when using UTF-8 box drawing symbols in
##   the Windows Console).
##
## .. code:: nim
##
##     TerminalBuffer* = ref object
##       width*: int
##       height*: int
##       buf*: seq[TerminalChar]
##       currBg*: BackgroundColor
##       currFg*: ForegroundColor
##       currStyle*: set[Style]
##       currX*: Natural
##       currY*: Natural
##
##   A virtual terminal buffer of a fixed width and height. It remembers the
##   current color and style settings and the current cursor position.
##
##   Write to the terminal buffer with `TerminalBuffer.write()` or access
##   the character buffer directly with the index operators.
##
##   Example:
##
##   .. code-block::
##        import illwill, unicode
##
##        # Initialise the console in non-fullscreen mode
##        illwillInit(fullscreen=false)
##
##        # Create a new terminal buffer
##        var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
##
##        # Write the character "X" at position (5,5) then read it back
##        tb[5,5] = TerminalChar(ch: "X".runeAt(0), fg: fgYellow, bg: bgNone, style: {})
##        let ch = tb[5,5]
##
##        # Write "foo" at position (10,10) in bright red
##        tb.setForegroundColor(fgRed, bright=true)
##        tb.setCursorPos(10, 10)
##        tb.write("foo")
##
##        # Write "bar" at position (15,12) in bright red, without changing
##        # the current cursor position
##        tb.write(15, 12, "bar")
##
##        tb.write(0, 20, "Normal ", fgYellow, "ESC", fgWhite,
##                        " or ", fgYellow, "Q", fgWhite, " to quit")
##
##        # Output the contents of the buffer to the terminal
##        tb.display()
##
##        # Clean up
##        illwillDeinit()
##

import macros, unicode

when defined(windows):
  import windows_terminal as env_terminal
elif defined(posix):
  import posix_terminal as env_terminal
elif defined(js):
  import js_terminal as env_terminal

export setControlCHook

import common

export ForegroundColor
export BackgroundColor
export Style
export Key
export IllwillError
export TerminalBuffer
export TerminalChar
export MouseButtonAction
export MouseInfo
export MouseButton
export ScrollDirection

proc terminalWidth*(): int =
  ## From the context of the current terminal, returns the number of columns.
  result = env_terminal.terminalWidth()

proc terminalHeight*(): int =
  ## From the context of the current terminal, returns the number of rows.
  result = env_terminal.terminalHeight()

proc terminalSize*(): tuple[w, h: int] =
  result = env_terminal.terminalSize()
  ## Returns the terminal width and height as a tuple. Internally calls
  ## terminalWidth and terminalHeight, so the same assumptions apply.

proc showCursor*() =
  ## Shows the terminal cursor. In other words, the cursor can be seen
  ## at it's current position by end user.
  env_terminal.showCursor()

proc hideCursor*() =
  ## Hides the terminal cursor. In other words, the cursor becomes hidden from
  ## the end user; even displaying new text.
  env_terminal.hideCursor()

proc getMouse*(): MouseInfo =
  ## When `illwillInit(mouse=true)` all mouse movements and clicks are captured.
  ## Call this to get the actual mouse informations. Also see `MouseInfo`.
  ##
  ## Example:
  ##
  ## .. code-block::
  ##
  ##  import illwill, os
  ##
  ##  proc exitProc() {.noconv.} =
  ##    illwillDeinit()
  ##    showCursor()
  ##    quit(0)
  ##
  ##  setControlCHook(exitProc)
  ##  illwillInit(mouse=true)
  ##
  ##  var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  ##
  ##  while true:
  ##    var key = getKey()
  ##    if key == Key.Mouse:
  ##      echo getMouse()
  ##    tb.display()
  ##    sleep(10)

  return gMouseInfo

when defined(posix):
  const
    XtermColor    = "xterm-color"
    Xterm256Color = "xterm-256color"

proc enterFullScreen() =
  ## Enters full-screen mode (clears the terminal).
  when defined(posix):
    case getEnv("TERM"):
    of XtermColor:
      stdout.write "\e7\e[?47h"
    of Xterm256Color:
      stdout.write "\e[?1049h"
    else:
      eraseScreen()
  else:
    eraseScreen()

proc exitFullScreen() =
  ## Exits full-screen mode (restores the previous contents of the terminal).
  when defined(posix):
    case getEnv("TERM"):
    of XtermColor:
      stdout.write "\e[2J\e[?47l\e8"
    of Xterm256Color:
      stdout.write "\e[?1049l"
    else:
      eraseScreen()
  else:
    eraseScreen()
    setCursorPos(0, 0)

proc illwillInit*(fullScreen: bool = true, mouse: bool = false) =
  ## Initializes the terminal and enables non-blocking keyboard input. Needs
  ## to be called before doing anything with the library.
  ##
  ## if fullScreen is set to true and the target is a POSIX terminal (MacOS,
  ## Linux, etc.), then the current screen is saved and will be restored
  ## when illwillDeinit is invoked.
  ##
  ## If mouse is set to true, all mouse actions are captured.
  ## Call `getMouse()` in your main loop to actually retrieve them.
  ##
  ## If the module is already intialised, `IllwillError` is raised.
  if gIllwillInitialised:
    raise newException(IllwillError, "Illwill already initialised")
  gFullScreen = fullScreen
  if gFullScreen: enterFullScreen()

  consoleInit()
  gMouse = mouse
  if gMouse:
    when defined(windows):
      enableMouse(getStdHandle(STD_INPUT_HANDLE))
    elif defined(posix):
      enableMouse()
    elif defined(js):
      discard
  gIllwillInitialised = true
  resetAttributes()

proc checkInit() =
  if not gIllwillInitialised:
    raise newException(IllwillError, "Illwill not initialised")

proc illwillDeinit*() =
  ## Resets the terminal to its previous state. Needs to be called before
  ## exiting the application.
  ##
  ## If the module is not intialised, `IllwillError` is raised.
  checkInit()
  if gFullScreen: exitFullScreen()
  if gMouse:
    when defined(windows):
      disableMouse(getStdHandle(STD_INPUT_HANDLE), gOldConsoleModeInput)
    elif defined(posix):
      disableMouse()
    elif defined(js):
      discard
  consoleDeinit()
  gIllwillInitialised = false
  resetAttributes()
  showCursor()

proc getKey*(): Key =
  ## Reads the next keystroke in a non-blocking manner. If there are no
  ## keypress events in the buffer, `Key.None` is returned.
  ##
  ## If a mouse event was captured `Key.Mouse` is returned.
  ## Call `getMouse()` to get the MouseInfo.
  ##
  ## If the module is not intialised, `IllwillError` is raised.
  checkInit()
  result = getKeyAsync()
  when defined(windows):
    if result == Key.None:
      if hasMouseInput():
        return Key.Mouse

proc fill*(tb: var TerminalBuffer, x1, y1, x2, y2: Natural, ch: string = " ") =
  ## Fills a rectangular area with the `ch` character using the current text
  ## attributes. The rectangle is clipped to the extends of the terminal
  ## buffer and the call can never fail.
  if x1 < tb.width and y1 < tb.height:
    let
      c = TerminalChar(ch: ch.runeAt(0), fg: tb.currFg, bg: tb.currBg,
                       style: tb.currStyle)

      xe = min(x2, tb.width-1)
      ye = min(y2, tb.height-1)

    for y in y1..ye:
      for x in x1..xe:
        tb[x, y] = c

proc clear*(tb: var TerminalBuffer, ch: string = " ") =
  ## Clears the contents of the terminal buffer with the `ch` character using
  ## the `fgNone` and `bgNone` attributes.
  tb.fill(0, 0, tb.width-1, tb.height-1, ch)

proc initTerminalBuffer(tb: var TerminalBuffer, width, height: Natural) =
  ## Initializes a new terminal buffer object of a fixed `width` and `height`.
  tb.width = width
  tb.height = height
  newSeq(tb.buf, width * height)
  tb.currBg = bgNone
  tb.currFg = fgNone
  tb.currStyle = {}

proc newTerminalBuffer*(width, height: Natural): TerminalBuffer =
  ## Creates a new terminal buffer of a fixed `width` and `height`.
  var tb = new TerminalBuffer
  tb.initTerminalBuffer(width, height)
  tb.clear()
  result = tb

func width*(tb: TerminalBuffer): Natural =
  ## Returns the width of the terminal buffer.
  result = tb.width

func height*(tb: TerminalBuffer): Natural =
  ## Returns the height of the terminal buffer.
  result = tb.height


proc copyFrom*(tb: var TerminalBuffer,
               src: TerminalBuffer, srcX, srcY, width, height: Natural,
               destX, destY: Natural) =
  ## Copies the contents of the `src` terminal buffer into this one.
  ## A rectangular area of dimension `width` and `height` is copied from
  ## the position `srcX` and `srcY` in the source buffer to the position
  ## `destX` and `destY` in this buffer.
  ##
  ## If the extents of the area to be copied lie outside the extents of the
  ## buffers, the copied area will be clipped to the available area (in other
  ## words, the call can never fail; in the worst case it just copies
  ## nothing).
  let
    srcWidth = max(src.width - srcX, 0)
    srcHeight = max(src.height - srcY, 0)
    destWidth = max(tb.width - destX, 0)
    destHeight = max(tb.height - destY, 0)
    w = min(min(srcWidth, destWidth), width)
    h = min(min(srcHeight, destHeight), height)

  for yOffs in 0..<h:
    for xOffs in 0..<w:
      tb[xOffs + destX, yOffs + destY] = src[xOffs + srcX, yOffs + srcY]


proc copyFrom*(tb: var TerminalBuffer, src: TerminalBuffer) =
  ## Copies the full contents of the `src` terminal buffer into this one.
  ##
  ## If the extents of the source buffer is greater than the extents of the
  ## destination buffer, the copied area is clipped to the destination area.
  tb.copyFrom(src, 0, 0, src.width, src.height, 0, 0)

proc newTerminalBufferFrom*(src: TerminalBuffer): TerminalBuffer =
  ## Creates a new terminal buffer with the dimensions of the `src` buffer and
  ## copies its contents into the new buffer.
  var tb = new TerminalBuffer
  tb.initTerminalBuffer(src.width, src.height)
  tb.copyFrom(src)
  result = tb

proc setCursorPos*(tb: var TerminalBuffer, x, y: Natural) =
  ## Sets the current cursor position. X is the column and Y is the row. Both
  ## columns and rows start at zero (0).
  tb.currX = x
  tb.currY = y

proc setCursorXPos*(tb: var TerminalBuffer, x: Natural) =
  ## Sets the current x (column) cursor position. Zero (0) is the first (left-most) column.
  tb.currX = x

proc setCursorYPos*(tb: var TerminalBuffer, y: Natural) =
  ## Sets the current y (row) cursor position. Zero (0) is the first (top) row.
  tb.currY = y

proc setBackgroundColor*(tb: var TerminalBuffer, bg: BackgroundColor) =
  ## Sets the current background color.
  tb.currBg = bg

proc setForegroundColor*(tb: var TerminalBuffer, fg: ForegroundColor,
                         bright: bool = false) =
  ## Sets the current foreground color and the bright style flag.
  if bright:
    incl(tb.currStyle, styleBright)
  else:
    excl(tb.currStyle, styleBright)
  tb.currFg = fg

proc setStyle*(tb: var TerminalBuffer, style: set[Style]) =
  ## Sets the current style flags.
  tb.currStyle = style

func getCursorPos*(tb: TerminalBuffer): tuple[x: Natural, y: Natural] =
  ## Returns the current cursor position. X is the column and Y is the row.
  result = (tb.currX, tb.currY)

func getCursorXPos*(tb: TerminalBuffer): Natural =
  ## Returns the current x (column) cursor position.
  result = tb.currX

func getCursorYPos*(tb: TerminalBuffer): Natural =
  ## Returns the current y (row) cursor position.
  result = tb.currY

func getBackgroundColor*(tb: var TerminalBuffer): BackgroundColor =
  ## Returns the current background color.
  result = tb.currBg

func getForegroundColor*(tb: var TerminalBuffer): ForegroundColor =
  ## Returns the current foreground color.
  result = tb.currFg

func getStyle*(tb: var TerminalBuffer): set[Style] =
  ## Returns the current style flags.
  result = tb.currStyle

proc resetAttributes*(tb: var TerminalBuffer) =
  ## Resets the current text attributes to `bgNone`, `fgWhite` and clears
  ## all style flags.
  tb.setBackgroundColor(bgNone)
  tb.setForegroundColor(fgWhite)
  tb.setStyle({})

proc write*(tb: var TerminalBuffer, x, y: Natural, s: string) =
  ## Writes `s` into the terminal buffer at the specified position using
  ## the current text attributes. Lines do not wrap and attempting to write
  ## outside the extents of the buffer will not raise an error; the output
  ## will be just cropped to the extents of the buffer.
  var currX = x
  for ch in runes(s):
    var c = TerminalChar(ch: ch, fg: tb.currFg, bg: tb.currBg,
                         style: tb.currStyle)
    tb[currX, y] = c
    inc(currX)
  tb.currX = currX
  tb.currY = y

proc write*(tb: var TerminalBuffer, s: string) =
  ## Writes `s` into the terminal buffer at the current cursor position using
  ## the current text attributes.
  write(tb, tb.currX, tb.currY, s)

var
  gPrevTerminalBuffer: TerminalBuffer
  gCurrBg: BackgroundColor
  gCurrFg: ForegroundColor
  gCurrStyle: set[Style]

proc setAttribs(c: TerminalChar) =
  if c.bg == bgNone or c.fg == fgNone or c.style == {}:
    resetAttributes()
    gCurrBg = c.bg
    gCurrFg = c.fg
    gCurrStyle = c.style
    if gCurrBg != bgNone:
      envSetBackgroundColor(gCurrBg.ord)
    if gCurrFg != fgNone:
      envSetForegroundColor(gCurrFg.ord)
    if gCurrStyle != {}:
      envSetStyle(gCurrStyle)
  else:
    if c.bg != gCurrBg:
      gCurrBg = c.bg
      envSetBackgroundColor(gCurrBg.ord)
    if c.fg != gCurrFg:
      gCurrFg = c.fg
      envSetForegroundColor(gCurrFg.ord)
    if c.style != gCurrStyle:
      gCurrStyle = c.style
      envSetStyle(gCurrStyle)

proc setPos(x, y: Natural) =
  setCursorPos(x, y)

proc setXPos(x: Natural) =
  setCursorXPos(x)

proc displayFull(tb: TerminalBuffer) =
  when defined(js):
    put tb
  else:
    var buf = ""

    proc flushBuf() =
      if buf.len > 0:
        put buf
        buf = ""

    for y in 0..<tb.height:
      setPos(0, y)
      for x in 0..<tb.width:
        let c = tb[x,y]
        if c.bg != gCurrBg or c.fg != gCurrFg or c.style != gCurrStyle:
          flushBuf()
          setAttribs(c)
        buf &= $c.ch
      flushBuf()


proc displayDiff(tb: TerminalBuffer) =
  when defined(js):
    put tb
  else:
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

    for y in 0..<tb.height:
      bufXPos = 0
      bufYPos = y
      for x in 0..<tb.width:
        let c = tb[x,y]
        if c != gPrevTerminalBuffer[x,y] or c.forceWrite:
          if c.bg != gCurrBg or c.fg != gCurrFg or c.style != gCurrStyle:
            flushBuf()
            bufXPos = x
            setAttribs(c)
          buf &= $c.ch
        else:
          flushBuf()
          bufXPos = x+1
      flushBuf()


var gDoubleBufferingEnabled = true

proc setDoubleBuffering*(enabled: bool) =
  ## Enables or disables double buffering (enabled by default).
  gDoubleBufferingEnabled = enabled
  gPrevTerminalBuffer = nil

proc hasDoubleBuffering*(): bool =
  ## Returns `true` if double buffering is enabled.
  ##
  ## If the module is not intialised, `IllwillError` is raised.
  checkInit()
  result = gDoubleBufferingEnabled

proc display*(tb: TerminalBuffer) =
  ## Outputs the contents of the terminal buffer to the actual terminal.
  ##
  ## If the module is not intialised, `IllwillError` is raised.
  checkInit()
  if not gFullRedrawNextFrame and gDoubleBufferingEnabled:
    if gPrevTerminalBuffer == nil:
      displayFull(tb)
      gPrevTerminalBuffer = newTerminalBufferFrom(tb)
    else:
      if tb.width == gPrevTerminalBuffer.width and
         tb.height == gPrevTerminalBuffer.height:
        displayDiff(tb)
        gPrevTerminalBuffer.copyFrom(tb)
      else:
        displayFull(tb)
        gPrevTerminalBuffer = newTerminalBufferFrom(tb)
    when not defined(js):
      flushFile(stdout)
  else:
    displayFull(tb)
    when not defined(js):
      flushFile(stdout)
    gFullRedrawNextFrame = false
  setCursorPos(tb.currX, tb.currY) # critical for an up-to-date visual cursor

type BoxChar = int

const
  LEFT   = 0x01
  RIGHT  = 0x02
  UP     = 0x04
  DOWN   = 0x08
  H_DBL  = 0x10
  V_DBL  = 0x20

  HORIZ = LEFT or RIGHT
  VERT  = UP or DOWN

var gBoxCharsUnicode: array[64, string]

gBoxCharsUnicode[0] = " "

gBoxCharsUnicode[   0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[   0 or  0 or     0 or LEFT] = "─"
gBoxCharsUnicode[   0 or  0 or RIGHT or    0] = "─"
gBoxCharsUnicode[   0 or  0 or RIGHT or LEFT] = "─"
gBoxCharsUnicode[   0 or UP or     0 or    0] = "│"
gBoxCharsUnicode[   0 or UP or     0 or LEFT] = "┘"
gBoxCharsUnicode[   0 or UP or RIGHT or    0] = "└"
gBoxCharsUnicode[   0 or UP or RIGHT or LEFT] = "┴"
gBoxCharsUnicode[DOWN or  0 or     0 or    0] = "│"
gBoxCharsUnicode[DOWN or  0 or     0 or LEFT] = "┐"
gBoxCharsUnicode[DOWN or  0 or RIGHT or    0] = "┌"
gBoxCharsUnicode[DOWN or  0 or RIGHT or LEFT] = "┬"
gBoxCharsUnicode[DOWN or UP or     0 or    0] = "│"
gBoxCharsUnicode[DOWN or UP or     0 or LEFT] = "┤"
gBoxCharsUnicode[DOWN or UP or RIGHT or    0] = "├"
gBoxCharsUnicode[DOWN or UP or RIGHT or LEFT] = "┼"

gBoxCharsUnicode[H_DBL or    0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[H_DBL or    0 or  0 or     0 or LEFT] = "═"
gBoxCharsUnicode[H_DBL or    0 or  0 or RIGHT or    0] = "═"
gBoxCharsUnicode[H_DBL or    0 or  0 or RIGHT or LEFT] = "═"
gBoxCharsUnicode[H_DBL or    0 or UP or     0 or    0] = "│"
gBoxCharsUnicode[H_DBL or    0 or UP or     0 or LEFT] = "╛"
gBoxCharsUnicode[H_DBL or    0 or UP or RIGHT or    0] = "╘"
gBoxCharsUnicode[H_DBL or    0 or UP or RIGHT or LEFT] = "╧"
gBoxCharsUnicode[H_DBL or DOWN or  0 or     0 or    0] = "│"
gBoxCharsUnicode[H_DBL or DOWN or  0 or     0 or LEFT] = "╕"
gBoxCharsUnicode[H_DBL or DOWN or  0 or RIGHT or    0] = "╒"
gBoxCharsUnicode[H_DBL or DOWN or  0 or RIGHT or LEFT] = "╤"
gBoxCharsUnicode[H_DBL or DOWN or UP or     0 or    0] = "│"
gBoxCharsUnicode[H_DBL or DOWN or UP or     0 or LEFT] = "╡"
gBoxCharsUnicode[H_DBL or DOWN or UP or RIGHT or    0] = "╞"
gBoxCharsUnicode[H_DBL or DOWN or UP or RIGHT or LEFT] = "╪"

gBoxCharsUnicode[V_DBL or    0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[V_DBL or    0 or  0 or     0 or LEFT] = "─"
gBoxCharsUnicode[V_DBL or    0 or  0 or RIGHT or    0] = "─"
gBoxCharsUnicode[V_DBL or    0 or  0 or RIGHT or LEFT] = "─"
gBoxCharsUnicode[V_DBL or    0 or UP or     0 or    0] = "║"
gBoxCharsUnicode[V_DBL or    0 or UP or     0 or LEFT] = "╜"
gBoxCharsUnicode[V_DBL or    0 or UP or RIGHT or    0] = "╙"
gBoxCharsUnicode[V_DBL or    0 or UP or RIGHT or LEFT] = "╨"
gBoxCharsUnicode[V_DBL or DOWN or  0 or     0 or    0] = "║"
gBoxCharsUnicode[V_DBL or DOWN or  0 or     0 or LEFT] = "╖"
gBoxCharsUnicode[V_DBL or DOWN or  0 or RIGHT or    0] = "╓"
gBoxCharsUnicode[V_DBL or DOWN or  0 or RIGHT or LEFT] = "╥"
gBoxCharsUnicode[V_DBL or DOWN or UP or     0 or    0] = "║"
gBoxCharsUnicode[V_DBL or DOWN or UP or     0 or LEFT] = "╢"
gBoxCharsUnicode[V_DBL or DOWN or UP or RIGHT or    0] = "╟"
gBoxCharsUnicode[V_DBL or DOWN or UP or RIGHT or LEFT] = "╫"

gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or     0 or    0] = " "
gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or     0 or LEFT] = "═"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or RIGHT or    0] = "═"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or  0 or RIGHT or LEFT] = "═"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or     0 or    0] = "║"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or     0 or LEFT] = "╝"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or RIGHT or    0] = "╚"
gBoxCharsUnicode[H_DBL or V_DBL or    0 or UP or RIGHT or LEFT] = "╩"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or     0 or    0] = "║"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or     0 or LEFT] = "╗"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or RIGHT or    0] = "╔"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or  0 or RIGHT or LEFT] = "╦"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or     0 or    0] = "║"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or     0 or LEFT] = "╣"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or RIGHT or    0] = "╠"
gBoxCharsUnicode[H_DBL or V_DBL or DOWN or UP or RIGHT or LEFT] = "╬"

proc toUTF8String(c: BoxChar): string = gBoxCharsUnicode[c]

type BoxBuffer* = ref object
  ## Box buffers are used to store the results of multiple consecutive box
  ## drawing calls. The idea is that when you draw a series of lines and
  ## rectangles into the buffer, the overlapping lines will get automatically
  ## connected by placing the appropriate UTF-8 symbols at the corner and
  ## junction points. The results can then be written to a terminal buffer.
  width: Natural
  height: Natural
  buf: seq[BoxChar]

proc newBoxBuffer*(width, height: Natural): BoxBuffer =
  ## Creates a new box buffer of a fixed `width` and `height`.
  result = new BoxBuffer
  result.width = width
  result.height = height
  newSeq(result.buf, width * height)

func width*(bb: BoxBuffer): Natural =
  ## Returns the width of the box buffer.
  result = bb.width

func height*(bb: BoxBuffer): Natural =
  ## Returns the height of the box buffer.
  result = bb.height

proc `[]=`(bb: var BoxBuffer, x, y: Natural, c: BoxChar) =
  if x < bb.width and y < bb.height:
    bb.buf[bb.width * y + x] = c

func `[]`(bb: BoxBuffer, x, y: Natural): BoxChar =
  if x < bb.width and y < bb.height:
    result = bb.buf[bb.width * y + x]

proc copyFrom*(bb: var BoxBuffer,
               src: BoxBuffer, srcX, srcY, width, height: Natural,
               destX, destY: Natural) =
  ## Copies the contents of the `src` box buffer into this one.
  ## A rectangular area of dimension `width` and `height` is copied from
  ## the position `srcX` and `srcY` in the source buffer to the position
  ## `destX` and `destY` in this buffer.
  ##
  ## If the extents of the area to be copied lie outside the extents of the
  ## buffers, the copied area will be clipped to the available area (in other
  ## words, the call can never fail; in the worst case it just copies
  ## nothing).
  let
    srcWidth = max(src.width - srcX, 0)
    srcHeight = max(src.height - srcY, 0)
    destWidth = max(bb.width - destX, 0)
    destHeight = max(bb.height - destY, 0)
    w = min(min(srcWidth, destWidth), width)
    h = min(min(srcHeight, destHeight), height)

  for yOffs in 0..<h:
    for xOffs in 0..<w:
      bb[xOffs + destX, yOffs + destY] = src[xOffs + srcX, yOffs + srcY]


proc copyFrom*(bb: var BoxBuffer, src: BoxBuffer) =
  ## Copies the full contents of the `src` box buffer into this one.
  ##
  ## If the extents of the source buffer is greater than the extents of the
  ## destination buffer, the copied area is clipped to the destination area.
  bb.copyFrom(src, 0, 0, src.width, src.height, 0, 0)

proc newBoxBufferFrom*(src: BoxBuffer): BoxBuffer =
  ## Creates a new box buffer with the dimensions of the `src` buffer and
  ## copies its contents into the new buffer.
  var bb = new BoxBuffer
  bb.copyFrom(src)
  result = bb

proc drawHorizLine*(bb: var BoxBuffer, x1, x2, y: Natural,
                    doubleStyle: bool = false, connect: bool = true) =
  ## Draws a horizontal line into the box buffer. Set `doubleStyle` to `true`
  ## to draw double lines. Set `connect` to `true` to connect overlapping
  ## lines.
  if y >= bb.height: return
  var xStart = x1
  var xEnd = x2
  if xStart > xEnd: swap(xStart, xEnd)
  if xStart >= bb.width: return

  xEnd = min(xEnd, bb.width-1)
  if connect:
    for x in xStart..xEnd:
      var c = bb[x,y]
      var h: int
      if x == xStart:
        h = if (c and LEFT) > 0: HORIZ else: RIGHT
      elif x == xEnd:
        h = if (c and RIGHT) > 0: HORIZ else: LEFT
      else:
        h = HORIZ
      if doubleStyle: h = h or H_DBL
      bb[x,y] = c or h
  else:
    for x in xStart..xEnd:
      var h = HORIZ
      if doubleStyle: h = h or H_DBL
      bb[x,y] = h


proc drawVertLine*(bb: var BoxBuffer, x, y1, y2: Natural,
                   doubleStyle: bool = false, connect: bool = true) =
  ## Draws a vertical line into the box buffer. Set `doubleStyle` to `true` to
  ## draw double lines. Set `connect` to `true` to connect overlapping lines.
  if x >= bb.width: return
  var yStart = y1
  var yEnd = y2
  if yStart > yEnd: swap(yStart, yEnd)
  if yStart >= bb.height: return

  yEnd = min(yEnd, bb.height-1)
  if connect:
    for y in yStart..yEnd:
      var c = bb[x,y]
      var v: int
      if y == yStart:
        v = if (c and UP) > 0: VERT else: DOWN
      elif y == yEnd:
        v = if (c and DOWN) > 0: VERT else: UP
      else:
        v = VERT
      if doubleStyle: v = v or V_DBL
      bb[x,y] = c or v
  else:
    for y in yStart..yEnd:
      var v = VERT
      if doubleStyle: v = v or V_DBL
      bb[x,y] = v


proc drawRect*(bb: var BoxBuffer, x1, y1, x2, y2: Natural,
               doubleStyle: bool = false, connect: bool = true) =
  ## Draws a rectangle into the box buffer. Set `doubleStyle` to `true` to
  ## draw double lines. Set `connect` to `true` to connect overlapping lines.
  if abs(x1-x2) < 1 or abs(y1-y2) < 1: return

  if connect:
    bb.drawHorizLine(x1, x2, y1, doubleStyle)
    bb.drawHorizLine(x1, x2, y2, doubleStyle)
    bb.drawVertLine(x1, y1, y2, doubleStyle)
    bb.drawVertLine(x2, y1, y2, doubleStyle)
  else:
    bb.drawHorizLine(x1+1, x2-1, y1, doubleStyle, connect = false)
    bb.drawHorizLine(x1+1, x2-1, y2, doubleStyle, connect = false)
    bb.drawVertLine(x1, y1+1, y2-1, doubleStyle, connect = false)
    bb.drawVertLine(x2, y1+1, y2-1, doubleStyle, connect = false)

    var c = RIGHT or DOWN
    if doubleStyle: c = c or V_DBL or H_DBL
    bb[x1,y1] = c

    c = LEFT or DOWN
    if doubleStyle: c = c or V_DBL or H_DBL
    bb[x2,y1] = c

    c = RIGHT or UP
    if doubleStyle: c = c or V_DBL or H_DBL
    bb[x1,y2] = c

    c = LEFT or UP
    if doubleStyle: c = c or V_DBL or H_DBL
    bb[x2,y2] = c


proc write*(tb: var TerminalBuffer, bb: var BoxBuffer) =
  ## Writes the contents of the box buffer into this terminal buffer with
  ## the current text attributes.
  let width = min(tb.width, bb.width)
  let height = min(tb.height, bb.height)
  var horizBoxCharCount: int
  var forceWrite: bool

  for y in 0..<height:
    horizBoxCharCount = 0
    forceWrite = false
    for x in 0..<width:
      let boxChar = bb[x,y]
      if boxChar > 0:
        if ((boxChar and LEFT) or (boxChar and RIGHT)) > 0:
          if horizBoxCharCount == 1:
            var prev = tb[x-1,y]
            prev.forceWrite = true
            tb[x-1,y] = prev
          if horizBoxCharCount >= 1:
            forceWrite = true
          inc(horizBoxCharCount)
        else:
          horizBoxCharCount = 0
          forceWrite = false

        var c = TerminalChar(ch: toUTF8String(boxChar).runeAt(0),
                             fg: tb.currFg, bg: tb.currBg,
                             style: tb.currStyle, forceWrite: forceWrite)
        tb[x,y] = c


type
  TerminalCmd* = enum  ## commands that can be expressed as arguments
    resetStyle         ## reset attributes

template writeProcessArg(tb: var TerminalBuffer, s: string) =
  tb.write(s)

template writeProcessArg(tb: var TerminalBuffer, style: Style) =
  tb.setStyle({style})

template writeProcessArg(tb: var TerminalBuffer, style: set[Style]) =
  tb.setStyle(style)

template writeProcessArg(tb: var TerminalBuffer, color: ForegroundColor) =
  tb.setForegroundColor(color)

template writeProcessArg(tb: var TerminalBuffer, color: BackgroundColor) =
  tb.setBackgroundColor(color)

template writeProcessArg(tb: var TerminalBuffer, cmd: TerminalCmd) =
  when cmd == resetStyle:
    tb.resetAttributes()

macro write*(tb: var TerminalBuffer, args: varargs[typed]): untyped =
  ## Special version of `write` that allows to intersperse text literals with
  ## set attribute commands.
  ##
  ## Example:
  ##
  ## .. code-block::
  ##   import illwill
  ##
  ##   illwillInit(fullscreen=false)
  ##
  ##   var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
  ##
  ##   tb.setForegroundColor(fgGreen)
  ##   tb.setBackgroundColor(bgBlue)
  ##   tb.write(0, 10, "before")
  ##
  ##   tb.write(0, 11, "unchanged", resetStyle, fgYellow, "yellow", bgRed, "red bg",
  ##                   styleBlink, "blink", resetStyle, "reset")
  ##
  ##   tb.write(0, 12, "after")
  ##
  ##   tb.display()
  ##
  ##   illwillDeinit()
  ##
  ## This will output the following:
  ##
  ## * 1st row:
  ##   - `before` with blue background, green foreground and default style
  ## * 2nd row:
  ##   - `unchanged` with blue background, green foreground and default style
  ##   - `yellow` with default background, yellow foreground and default style
  ##   - `red bg` with red background, yellow foreground and default style
  ##   - `blink` with red background, yellow foreground and blink style (if
  ##     supported by the terminal)
  ##   - `reset` with the default background and foreground and default style
  ## * 3rd row:
  ##   - `after` with the default background and foreground and default style
  ##
  ##
  result = newNimNode(nnkStmtList)

  if args.len >= 3 and
     args[0].typeKind() == ntyInt and args[1].typeKind() == ntyInt:

    let x = args[0]
    let y = args[1]
    result.add(newCall(bindSym"setCursorPos", tb, x, y))
    for i in 2..<args.len:
      let item = args[i]
      result.add(newCall(bindSym"writeProcessArg", tb, item))
  else:
    for item in args.items:
      result.add(newCall(bindSym"writeProcessArg", tb, item))


proc drawHorizLine*(tb: var TerminalBuffer, x1, x2, y: Natural,
                    doubleStyle: bool = false) =
  ## Convenience method to draw a single horizontal line into a terminal
  ## buffer directly.
  var bb = newBoxBuffer(tb.width, tb.height)
  bb.drawHorizLine(x1, x2, y, doubleStyle)
  tb.write(bb)

proc drawVertLine*(tb: var TerminalBuffer, x, y1, y2: Natural,
                   doubleStyle: bool = false) =
  ## Convenience method to draw a single vertical line into a terminal buffer
  ## directly.
  var bb = newBoxBuffer(tb.width, tb.height)
  bb.drawVertLine(x, y1, y2, doubleStyle)
  tb.write(bb)

proc drawRect*(tb: var TerminalBuffer, x1, y1, x2, y2: Natural,
               doubleStyle: bool = false) =
  ## Convenience method to draw a rectangle into a terminal buffer directly.
  var bb = newBoxBuffer(tb.width, tb.height)
  bb.drawRect(x1, y1, x2, y2, doubleStyle)
  tb.write(bb)

var
  userInputText = ""
  userInputExitKey = Key.None
  userInputMaxLen = 1
  userInputColumn = 0
  userInputAllowTabArrow = false

proc startInputLine*(
                      tb: var TerminalBuffer, 
                      x: int, 
                      y: int, 
                      strDefault: string, 
                      strLen: int, 
                      allowTabArrowExit = false
                    ) =
  ## Setup the terminal for gathering text from the terminal user.
  ##
  ## The ``strDefault`` value is displayed at the column (x) and row(y). The
  ## cursor is then moved to the end of that value and shown.
  ##
  ## If the column is too close the right edge fo the screen, then the length
  ## is adjusted to account for that.
  ##
  ## This procedure does NOT actually gather then number. Instead, future calls
  ## to ``inputLineReady`` will process future keypresses to build the string
  ## and determine if the string is ready to be used.
  ##
  ## By default, only Enter (on Windows/POSIX) will finish the string entry (or
  ## Ctrl-Enter on Javascript.) However, if ``allowTabArrowExit`` is set to true
  ## then Escape, Up, Down, and Tab will also finish the entry.
  var goodX = x
  userInputText = strDefault
  userInputExitKey = Key.None
  userInputAllowTabArrow = allowTabArrowExit
  if strLen > 0:
    let remainingSpace = tb.width - x - 2
    if remainingSpace < 1:
      goodX = tb.width - 2
      userInputMaxLen = 1
    elif remainingSpace < strLen:
      userInputMaxLen = remainingSpace
    else:
      userInputMaxLen = strLen
  else:
    userInputMaxLen = 1
  tb.setCursorPos(goodX, y)
  showCursor()
  userInputColumn = goodX
  if strDefault.len > 0:
    tb.write(strDefault)
  tb.display()

proc inputLineReady*(tb: var TerminalBuffer): bool =
  ## This procedure both processes any incoming keys pressed (building the string),
  ## but also returns a bool of true when the string is ready.
  ##
  ## When this value is true, any further processing is finished until ``startInputLine``
  ## restarts the whole process from the beginning again.
  ##
  ## If you wish to get the string, call ``getInputLineText``.
  ##
  ## If you wish to get the Key that caused the the process to stop, call 
  ## ``getInputLineExitKey``.
  if userInputExitKey != Key.None:
    result = true
    return
  result = false

  let key = getKey()
  case key
  of Key.None:
    discard
  of Key.Enter:
    result = true
    userInputExitKey = key
    hideCursor()
  of Key.Tab:
    if userInputAllowTabArrow:
      result = true
      userInputExitKey = key
      hideCursor()
  of Key.Up:
    if userInputAllowTabArrow:
      result = true
      userInputExitKey = key
      hideCursor()
  of Key.Down:
    if userInputAllowTabArrow:
      result = true
      userInputExitKey = key
      hideCursor()
  of Key.Escape:
    if userInputAllowTabArrow:
      result = true
      userInputExitKey = key
      hideCursor()
  of Key.Backspace:
    if userInputText.len > 0:
      userInputText = userInputText[0 .. ^2]
      tb.setCursorXPos(userInputColumn + userInputText.len)
      tb.write(" ")
      tb.setCursorXPos(userInputColumn + userInputText.len)
  else:
    let r = key.toRunes
    if r.len > 0:
      if userInputText.len < userInputMaxLen:
        tb.write($r)
        userInputText &= $r

proc getInputLineText*(): string =
  ## Get the current string being built (or finished being built) by the
  ## ``inputLineReady`` procedure and started by the ``startInputLine`` procedure.
  result = userInputText

proc getInputLineExitKey*(): Key =
  ## Get the reason that the ``startInputLine`` / ``inputLineReady`` process
  ## ended. If the process has not ended (or was never started), you will get a
  ## value of Key.None.
  result = userInputExitKey


template timerLoop*(msDelay: int, content: untyped): untyped =
  ## Most *illwill* programs are run as an infinite loop.
  ##
  ## In the context of a binary executable, such as when your program is
  ## compiled for Windows or POSIX (MacOS/Linux), then this is literally
  ## a ``while true:`` loop with a sleep period between each loop such as:
  ##
  ## .. code-block::
  ##
  ##     while true:
  ##       #
  ##       # your stuff goes here
  ##       #
  ##       tb.display()
  ##       sleep(20)
  ##
  ## But when compiling for Javascript, this does not work because Web Browsers
  ## are event-driven. In fact, using an infinite loop would "lock up" the web page
  ## and prevent it from ever displaying anything.
  ##
  ## So, to prevent that, this universal template has been written to handle
  ## all four environments (Windows, MacOS, Linux, and Javascript).
  ##
  ## Simply use this template as a replacment for the ``while`` and ``sleep``
  ## calls:
  ##
  ## .. code-block::
  ##
  ##     timerLoop(20):
  ##       #
  ##       # your stuff goes here
  ##       #
  ##       tb.display()
  ##
  ## Behind the scenes, the compiler target is detected and the correct loop
  ## handling is invoked.
  env_terminal.timerLoop(msDelay, content)


proc illwillOnLoad*(domId: cstring, cols, rows: int) {.exportc.} =
  ## When using *illwill* to make Javascript, this is the 
  ## routine that starts treating the target PRE element as a terminal.
  ##
  ## At minimum, the HTML should have:
  ##
  ## .. code-block::
  ##
  ##     <html>
  ##       <head>
  ##         <script src="mycode.js"></script>
  ##       </head>
  ##       <body onload="illwillOnLoad('terminal', 80, 24);">
  ##         <pre id="terminal">
  ##            initializing...
  ##         </pre>
  ##       </body>
  ##     </html>
  ##
  ## Of note:
  ##
  ##  - the compiled javascript script (``mycode.js``) is loaded. It is safe to
  ##    do this in the header.
  ##  - this procedure is only called after the body of the page loads. The ``domId``
  ##    is the *id* of the ``pre`` element. The column and row sizes are determined
  ##    beforehand, regardless of the CSS/browser styling of the ``pre``.
  ##  - this routine should be called from within the html as shown. It is NOT
  ##    meant to be called more than once.
  when defined(js):
    env_terminal.illWillOnLoad(domId, cols, rows)
  else:
    discard

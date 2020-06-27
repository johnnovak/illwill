import unicode

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

  Style* = enum
    styleBright = 1,        ## bright text
    styleDim,               ## dim text
    styleItalic,            ## italic (or reverse on terminals not supporting)
    styleUnderscore,        ## underscored text
    styleBlink,             ## blinking/bold text
    styleBlinkRapid,        ## rapid blinking/bold text (not widely supported)
    styleReverse,           ## reverse
    styleHidden,            ## hidden text
    styleStrikethrough      ## strikethrough

  Key* {.pure.} = enum      ## Supported single key presses and key combinations
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
    F12 = (1022, "F12"),

    Mouse = (5000, "Mouse")

  IllwillError* = object of Exception

type
  MouseButtonAction* {.pure.} = enum
    mbaNone, mbaPressed, mbaReleased
  MouseInfo* = object
    x*: int ## x mouse position
    y*: int ## y mouse position
    button*: MouseButton ## which button was pressed
    action*: MouseButtonAction ## if button was released or pressed
    ctrl*: bool ## was ctrl was down on event
    shift*: bool ## was shift was down on event
    scroll*: bool ## if this is a mouse scroll
    scrollDir*: ScrollDirection
    move*: bool ## if this a mouse move
  MouseButton* {.pure.} = enum
    mbNone, mbLeft, mbMiddle, mbRight
  ScrollDirection* {.pure.} = enum
    sdNone, sdUp, sdDown

type
  TerminalChar* = object
    ## Represents a character in the terminal buffer, including color and
    ## style information.
    ##
    ## If `forceWrite` is set to `true`, the character is always output even
    ## when double buffering is enabled (this is a hack to achieve better
    ## continuity of horizontal lines when using UTF-8 box drawing symbols in
    ## the Windows Console).
    ch*: Rune
    fg*: ForegroundColor
    bg*: BackgroundColor
    style*: set[Style]
    forceWrite*: bool

  TerminalBuffer* = ref object
    ## A virtual terminal buffer of a fixed width and height. It remembers the
    ## current color and style settings and the current cursor position.
    ##
    ## Write to the terminal buffer with `TerminalBuffer.write()` or access
    ## the character buffer directly with the index operators.
    ##
    ## Example:
    ##
    ## .. code-block::
    ##   import illwill, unicode
    ##
    ##   # Initialise the console in non-fullscreen mode
    ##   illwillInit(fullscreen=false)
    ##
    ##   # Create a new terminal buffer
    ##   var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
    ##
    ##   # Write the character "X" at position (5,5) then read it back
    ##   tb[5,5] = TerminalChar(ch: "X".runeAt(0), fg: fgYellow, bg: bgNone, style: {})
    ##   let ch = tb[5,5]
    ##
    ##   # Write "foo" at position (10,10) in bright red
    ##   tb.setForegroundColor(fgRed, bright=true)
    ##   tb.setCursorPos(10, 10)
    ##   tb.write("foo")
    ##
    ##   # Write "bar" at position (15,12) in bright red, without changing
    ##   # the current cursor position
    ##   tb.write(15, 12, "bar")
    ##
    ##   tb.write(0, 20, "Normal ", fgYellow, "ESC", fgWhite,
    ##                   " or ", fgYellow, "Q", fgWhite, " to quit")
    ##
    ##   # Output the contents of the buffer to the terminal
    ##   tb.display()
    ##
    ##   # Clean up
    ##   illwillDeinit()
    ##
    width*: int
    height*: int
    buf*: seq[TerminalChar]
    currBg*: BackgroundColor
    currFg*: ForegroundColor
    currStyle*: set[Style]
    currX*: Natural
    currY*: Natural

var gMouseInfo* = MouseInfo()
var gMouse*: bool = false

var gIllwillInitialised* = false
var gFullScreen* = false
var gFullRedrawNextFrame* = false

proc `[]=`*(tb: var TerminalBuffer, x, y: Natural, ch: TerminalChar) =
  ## Index operator to write a character into the terminal buffer at the
  ## specified location. Does nothing if the location is outside of the
  ## extents of the terminal buffer.
  if x < tb.width and y < tb.height:
    tb.buf[tb.width * y + x] = ch

proc `[]`*(tb: TerminalBuffer, x, y: Natural): TerminalChar =
  ## Index operator to read a character from the terminal buffer at the
  ## specified location. Returns nil if the location is outside of the extents
  ## of the terminal buffer.
  if x < tb.width and y < tb.height:
    result = tb.buf[tb.width * y + x]

func toKey*(c: int): Key =
  try:
    result = Key(c)
  except RangeError:  # ignore unknown keycodes
    result = Key.None

func toRunes*(k: Key): seq[Rune] {.used.} =
  case k:
  of Space:
    result=" ".toRunes
  of ExclamationMark:
    result="!".toRunes
  of DoubleQuote:
    result="\"".toRunes
  of Hash:
    result="#".toRunes
  of Dollar:
    result="$".toRunes
  of Percent:
    result="%".toRunes
  of Ampersand:
    result="&".toRunes
  of SingleQuote:
    result="'".toRunes
  of LeftParen:
    result="(".toRunes
  of RightParen:
    result=")".toRunes
  of Asterisk:
    result="*".toRunes
  of Plus:
    result="+".toRunes
  of Comma:
    result=",".toRunes
  of Minus:
    result="-".toRunes
  of Dot:
    result=".".toRunes
  of Slash:
    result="/".toRunes
  of Zero:
    result="0".toRunes
  of One:
    result="1".toRunes
  of Two:
    result="2".toRunes
  of Three:
    result="3".toRunes
  of Four:
    result="4".toRunes
  of Five:
    result="5".toRunes
  of Six:
    result="6".toRunes
  of Seven:
    result="7".toRunes
  of Eight:
    result="8".toRunes
  of Nine:
    result="9".toRunes
  of Colon:
    result=":".toRunes
  of Semicolon:
    result=";".toRunes
  of LessThan:
    result="<".toRunes
  of Equals:
    result="=".toRunes
  of GreaterThan:
    result=">".toRunes
  of QuestionMark:
    result="?".toRunes
  of At:
    result="@".toRunes
  of ShiftA:
    result="A".toRunes
  of ShiftB:
    result="B".toRunes
  of ShiftC:
    result="C".toRunes
  of ShiftD:
    result="D".toRunes
  of ShiftE:
    result="E".toRunes
  of ShiftF:
    result="F".toRunes
  of ShiftG:
    result="G".toRunes
  of ShiftH:
    result="H".toRunes
  of ShiftI:
    result="I".toRunes
  of ShiftJ:
    result="J".toRunes
  of ShiftK:
    result="K".toRunes
  of ShiftL:
    result="L".toRunes
  of ShiftM:
    result="M".toRunes
  of ShiftN:
    result="N".toRunes
  of ShiftO:
    result="O".toRunes
  of ShiftP:
    result="P".toRunes
  of ShiftQ:
    result="Q".toRunes
  of ShiftR:
    result="R".toRunes
  of ShiftS:
    result="S".toRunes
  of ShiftT:
    result="T".toRunes
  of ShiftU:
    result="U".toRunes
  of ShiftV:
    result="V".toRunes
  of ShiftW:
    result="W".toRunes
  of ShiftX:
    result="X".toRunes
  of ShiftY:
    result="Y".toRunes
  of ShiftZ:
    result="Z".toRunes
  of LeftBracket:
    result="[".toRunes
  of Backslash:
    result="\\".toRunes
  of RightBracket:
    result="]".toRunes
  of Caret:
    result="^".toRunes
  of Underscore:
    result="_".toRunes
  of GraveAccent:
    result="`".toRunes
  of A:
    result="a".toRunes
  of B:
    result="b".toRunes
  of C:
    result="c".toRunes
  of D:
    result="d".toRunes
  of E:
    result="e".toRunes
  of F:
    result="f".toRunes
  of G:
    result="g".toRunes
  of H:
    result="h".toRunes
  of I:
    result="i".toRunes
  of J:
    result="j".toRunes
  of K:
    result="k".toRunes
  of L:
    result="l".toRunes
  of M:
    result="m".toRunes
  of N:
    result="n".toRunes
  of O:
    result="o".toRunes
  of P:
    result="p".toRunes
  of Q:
    result="q".toRunes
  of R:
    result="r".toRunes
  of S:
    result="s".toRunes
  of T:
    result="t".toRunes
  of U:
    result="u".toRunes
  of V:
    result="v".toRunes
  of W:
    result="w".toRunes
  of X:
    result="x".toRunes
  of Y:
    result="y".toRunes
  of Z:
    result="z".toRunes
  of LeftBrace:
    result="{".toRunes
  of Pipe:
    result="|".toRunes
  of RightBrace:
    result="}".toRunes
  of Tilde:
    result="~".toRunes
  else:
    result = @[]

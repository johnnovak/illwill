import 
  encodings, 
  unicode, 
  winlean,
  bitops,
  terminal

export terminalWidth
export terminalHeight
export terminalSize
export hideCursor
export showCursor
export getStdHandle
export STD_INPUT_HANDLE

import common

export resetAttributes
export eraseScreen
export setCursorPos
export setCursorXPos

# export getEnv

proc envSetForegroundColor*(bg: int) =
  setForegroundColor(terminal.ForegroundColor(bg))

proc envSetBackgroundColor*(bg: int) =
  setBackgroundColor(terminal.BackgroundColor(bg))

proc envSetStyle*(style: set[common.Style]) =
  var newStyle: set[terminal.Style] = {}
  for s in style.items:
    newStyle.incl(terminal.Style(s))
  setStyle(newStyle)

template timerLoop*(msDelay: int, content: untyped): untyped =
  while true:
    content
    sleep(msDelay)

proc kbhit(): cint {.importc: "_kbhit", header: "<conio.h>".}
proc getch(): cint {.importc: "_getch", header: "<conio.h>".}

proc getConsoleMode(hConsoleHandle: Handle, dwMode: ptr DWORD): WINBOOL {.
    stdcall, dynlib: "kernel32", importc: "GetConsoleMode".}

proc setConsoleMode(hConsoleHandle: Handle, dwMode: DWORD): WINBOOL {.
    stdcall, dynlib: "kernel32", importc: "SetConsoleMode".}

# Mouse
const
  INPUT_BUFFER_LEN = 512
const
  ENABLE_MOUSE_INPUT = 0x10
  ENABLE_WINDOW_INPUT = 0x8
  ENABLE_QUICK_EDIT_MODE = 0x40
  ENABLE_EXTENDED_FLAGS = 0x80
  MOUSE_EVENT = 0x0002

const
  FROM_LEFT_1ST_BUTTON_PRESSED = 0x0001
  FROM_LEFT_2ND_BUTTON_PRESSED = 0x0004
  RIGHTMOST_BUTTON_PRESSED = 0x0002

const
  LEFT_CTRL_PRESSED = 0x0008
  RIGHT_CTRL_PRESSED = 0x0004
  SHIFT_PRESSED = 0x0010

const
  MOUSE_WHEELED = 0x0004

type
  WCHAR = WinChar
  CHAR = char
  BOOL = WINBOOL
  WORD = uint16
  UINT = cint
  SHORT = int16

# The windows console input structures.
type
  KEY_EVENT_RECORD_UNION* {.bycopy, union.} = object
    UnicodeChar*: WCHAR
    AsciiChar*: CHAR

  INPUT_RECORD_UNION* {.bycopy, union.} = object
    KeyEvent*: KEY_EVENT_RECORD
    MouseEvent*: MOUSE_EVENT_RECORD
    WindowBufferSizeEvent*: WINDOW_BUFFER_SIZE_RECORD
    MenuEvent*: MENU_EVENT_RECORD
    FocusEvent*: FOCUS_EVENT_RECORD

  COORD* {.bycopy.} = object
    X*: SHORT
    Y*: SHORT

  PCOORD* = ptr COORD
  FOCUS_EVENT_RECORD* {.bycopy.} = object
    bSetFocus*: BOOL

  KEY_EVENT_RECORD* {.bycopy.} = object
    bKeyDown*: BOOL
    wRepeatCount*: WORD
    wVirtualKeyCode*: WORD
    wVirtualScanCode*: WORD
    uChar*: KEY_EVENT_RECORD_UNION
    dwControlKeyState*: DWORD

  MENU_EVENT_RECORD* {.bycopy.} = object
    dwCommandId*: UINT

  PMENU_EVENT_RECORD* = ptr MENU_EVENT_RECORD
  MOUSE_EVENT_RECORD* {.bycopy.} = object
    dwMousePosition*: COORD
    dwButtonState*: DWORD
    dwControlKeyState*: DWORD
    dwEventFlags*: DWORD

  WINDOW_BUFFER_SIZE_RECORD* {.bycopy.} = object
    dwSize*: COORD

  INPUT_RECORD* {.bycopy.} = object
    EventType*: WORD
    Event*: INPUT_RECORD_UNION

type
  PINPUT_RECORD = ptr array[INPUT_BUFFER_LEN, INPUT_RECORD]
  LPDWORD = PDWORD

proc peekConsoleInputA(hConsoleInput: HANDLE, lpBuffer: PINPUT_RECORD, nLength: DWORD, lpNumberOfEventsRead: LPDWORD): WINBOOL
  {.stdcall, dynlib: "kernel32", importc: "PeekConsoleInputA".}

const
  ENABLE_WRAP_AT_EOL_OUTPUT   = 0x0002

var gOldConsoleModeInput*: DWORD
var gOldConsoleMode*: DWORD

proc consoleInit*() =
  discard getConsoleMode(getStdHandle(STD_INPUT_HANDLE), gOldConsoleModeInput.addr)
  if gFullScreen:
    if getConsoleMode(getStdHandle(STD_OUTPUT_HANDLE), gOldConsoleMode.addr) != 0:
      var mode = gOldConsoleMode and (not ENABLE_WRAP_AT_EOL_OUTPUT)
      discard setConsoleMode(getStdHandle(STD_OUTPUT_HANDLE), mode)

proc consoleDeinit*() =
  discard setConsoleMode(getStdHandle(STD_OUTPUT_HANDLE), gOldConsoleMode)


func getKeyAsync*(): Key =
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

proc put*(s: string) =
  var us = utf16LEConverter.convert(s)
  var numWritten: DWORD
  discard writeConsole(hStdout, pointer(us[0].addr), DWORD(s.runeLen),
                       numWritten.addr, nil)

proc enableMouse*(hConsoleInput: Handle) =
  var currentMode: DWORD
  discard getConsoleMode(hConsoleInput, currentMode.addr)
  discard setConsoleMode(hConsoleInput,
    ENABLE_WINDOW_INPUT or ENABLE_MOUSE_INPUT or ENABLE_EXTENDED_FLAGS or
    (currentMode and ENABLE_QUICK_EDIT_MODE.bitnot())
  )

proc disableMouse*(hConsoleInput: Handle, oldConsoleMode: DWORD) =
  discard setConsoleMode(hConsoleInput, oldConsoleMode) # TODO: REMOVE MOUSE OPTION ONLY?

var gLastMouseInfo* = MouseInfo()

proc fillGlobalMouseInfo(inputRecord: INPUT_RECORD) =
  gMouseInfo.x = inputRecord.Event.MouseEvent.dwMousePosition.X
  gMouseInfo.y = inputRecord.Event.MouseEvent.dwMousePosition.Y

  case inputRecord.Event.MouseEvent.dwButtonState
  of FROM_LEFT_1ST_BUTTON_PRESSED:
    gMouseInfo.button = mbLeft
  of FROM_LEFT_2ND_BUTTON_PRESSED:
    gMouseInfo.button = mbMiddle
  of RIGHTMOST_BUTTON_PRESSED:
    gMouseInfo.button = mbRight
  else:
    gMouseInfo.button = mbNone

  if gMouseInfo.button != mbNone:
    gMouseInfo.action = MouseButtonAction.mbaPressed
  elif gMouseInfo.button == mbNone and gLastMouseInfo.button != mbNone:
    gMouseInfo.action = MouseButtonAction.mbaReleased
  else:
    gMouseInfo.action = MouseButtonAction.mbaNone

  if gLastMouseInfo.x != gMouseInfo.x or gLastMouseInfo.y != gMouseInfo.y:
    gMouseInfo.move = true
  else:
    gMouseInfo.move = false

  if bitand(inputRecord.Event.MouseEvent.dwEventFlags, MOUSE_WHEELED) == MOUSE_WHEELED:
    gMouseInfo.scroll = true
    if inputRecord.Event.MouseEvent.dwButtonState.testBit(31):
      gMouseInfo.scrollDir = ScrollDirection.sdDown
    else:
      gMouseInfo.scrollDir = ScrollDirection.sdUp
  else:
    gMouseInfo.scroll = false
    gMouseInfo.scrollDir = ScrollDirection.sdNone

  gMouseInfo.ctrl = bitand(inputRecord.Event.MouseEvent.dwControlKeyState, LEFT_CTRL_PRESSED) == LEFT_CTRL_PRESSED or
      bitand(inputRecord.Event.MouseEvent.dwControlKeyState, RIGHT_CTRL_PRESSED) == RIGHT_CTRL_PRESSED

  gMouseInfo.shift = bitand(inputRecord.Event.MouseEvent.dwControlKeyState, SHIFT_PRESSED) == SHIFT_PRESSED

  gLastMouseInfo = gMouseInfo


proc hasMouseInput*(): bool =
  var buffer: array[INPUT_BUFFER_LEN, INPUT_RECORD]
  var numberOfEventsRead: DWORD
  var toRead: int = 0
  discard peekConsoleInputA(getStdHandle(STD_INPUT_HANDLE), buffer.addr, buffer.len.DWORD, numberOfEventsRead.addr)
  if numberOfEventsRead == 0: return false
  for inputRecord in buffer[0..<numberOfEventsRead.int]:
    toRead.inc()
    if inputRecord.EventType == MOUSE_EVENT: break
  if toRead == 0: return false
  discard readConsoleInput(getStdHandle(STD_INPUT_HANDLE), buffer.addr, toRead.DWORD, numberOfEventsRead.addr)
  if buffer[numberOfEventsRead - 1].EventType == MOUSE_EVENT:
    fillGlobalMouseInfo(buffer[numberOfEventsRead - 1])
    return true
  else:
    return false

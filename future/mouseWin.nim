import winlean
import bitops
import illwill

type
  WCHAR = WinChar
  CHAR = char
  BOOL = WINBOOL
  WORD = uint16
  UINT = cint
  SHORT = int16

include m

type
  PINPUT_RECORD = ptr array[1024, INPUT_RECORD]
  LPDWORD = PDWORD

const
  ENABLE_MOUSE_INPUT* = 0x10
  ENABLE_WINDOW_INPUT* = 0x8
  ENABLE_QUICK_EDIT_MODE* = 0x40
  ENABLE_EXTENDED_FLAGS* = 0x80
  # ENABLE_VIRTUAL_TERMINAL_INPUT* = 0x0200
  MOUSE_EVENT* = 0x0002


const
  FROM_LEFT_1ST_BUTTON_PRESSED* = 0x0001
  FROM_LEFT_2ND_BUTTON_PRESSED* = 0x0004
  FROM_LEFT_3RD_BUTTON_PRESSED* = 0x0008
  FROM_LEFT_4TH_BUTTON_PRESSED* = 0x0010
  RIGHTMOST_BUTTON_PRESSED* = 0x0002

# BOOL WINAPI PeekConsoleInput(
#   _In_  HANDLE        hConsoleInput,
#   _Out_ PINPUT_RECORD lpBuffer,
#   _In_  DWORD         nLength,
#   _Out_ LPDWORD       lpNumberOfEventsRead
# );
proc PeekConsoleInputA(hConsoleInput: HANDLE, lpBuffer: PINPUT_RECORD, nLength: DWORD, lpNumberOfEventsRead: LPDWORD): WINBOOL
  {.stdcall, dynlib: "kernel32", importc.}

# BOOL WINAPI SetConsoleMode(
#   _In_ HANDLE hConsoleHandle,
#   _In_ DWORD  dwMode
# );
proc SetConsoleMode(hConsoleHandle: HANDLE, dwMode: DWORD): WINBOOL {.stdcall, dynlib: "kernel32", importc.}

# BOOL WINAPI GetConsoleMode(
#   _In_  HANDLE  hConsoleHandle,
#   _Out_ LPDWORD lpMode
# );
proc GetConsoleMode(hConsoleHandle: HANDLE, lpMode: LPDWORD): WINBOOL {.stdcall, dynlib: "kernel32", importc.}


when isMainModule:
  import os

  illwillInit(fullscreen=true, mouseMode = TrackAny)
  hideCursor()

  var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

  var hConsoleInput: HANDLE = getStdHandle(STD_INPUT_HANDLE)
  var buffer: array[1024, INPUT_RECORD]
  var numberOfEventsRead: DWORD
  var prevMode: DWORD

  if GetConsoleMode(hConsoleInput, addr prevMode) == 0:
    echo getLastError()

  if SetConsoleMode(hConsoleInput, ENABLE_WINDOW_INPUT or ENABLE_MOUSE_INPUT or ENABLE_EXTENDED_FLAGS or (prev_mode and ENABLE_QUICK_EDIT_MODE.bitnot())) == 0:
    echo getLastError()

  var idx = 0
  while true:
    if PeekConsoleInputA(hConsoleInput, addr buffer, buffer.len.DWORD, addr numberOfEventsRead) == 0:
      echo getLastError()

    if readConsoleInput(hConsoleInput, addr buffer, buffer.len.DWORD, addr numberOfEventsRead) == 0:
      echo getLastError()

    var lastMi: MouseInfo
    for elem in buffer[0..numberOfEventsRead.int-1]:
      # Filter for only MOUSE_EVENT
      if elem.EventType != MOUSE_EVENT: continue

      var mi = MouseInfo()
      mi.x = elem.Event.MouseEvent.dwMousePosition.X
      mi.y = elem.Event.MouseEvent.dwMousePosition.Y

      case elem.Event.MouseEvent.dwButtonState
      of FROM_LEFT_1ST_BUTTON_PRESSED:
        mi.button = ButtonLeft
      of FROM_LEFT_2ND_BUTTON_PRESSED:
        mi.button = ButtonMiddle
      of RIGHTMOST_BUTTON_PRESSED:
        mi.button = ButtonRight
      else:
        mi.button = ButtonNone

      if lastMi.button == ButtonNone and mi.button != ButtonNone:
        mi.action = MouseButtonAction.Pressed
      else:
        mi.action = MouseButtonAction.Released

      if lastMi.x != mi.x or lastMi.y != mi.y:
        mi.move = true
      else:
        mi.move = false

      lastMi = mi

      tb.write 0, 0, $mi
      tb.display()

    idx.inc
    if idx == 100: break
    sleep(50)

  if SetConsoleMode(hConsoleInput,  prevMode) == 0:
    echo getLastError()
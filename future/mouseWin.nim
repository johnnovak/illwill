import winlean
import bitops
# import illwill

const
  ENABLE_MOUSE_INPUT* = 0x10
  ENABLE_WINDOW_INPUT* = 0x8
  ENABLE_QUICK_EDIT_MODE* = 0x40
  ENABLE_EXTENDED_FLAGS* = 0x80
  MOUSE_EVENT* = 0x0002

const
  FROM_LEFT_1ST_BUTTON_PRESSED* = 0x0001
  FROM_LEFT_2ND_BUTTON_PRESSED* = 0x0004
  FROM_LEFT_3RD_BUTTON_PRESSED* = 0x0008
  FROM_LEFT_4TH_BUTTON_PRESSED* = 0x0010
  RIGHTMOST_BUTTON_PRESSED* = 0x0002

const
  # CAPSLOCK_ON* = 0x0080
  # #The CAPS LOCK light is on.

  # ENHANCED_KEY* = 0x0100
  # #The key is enhanced.

  # LEFT_ALT_PRESSED* = 0x0002
  # #The left ALT key is pressed.

  LEFT_CTRL_PRESSED* = 0x0008
  #The left CTRL key is pressed.

  # NUMLOCK_ON* = 0x0020
  # #The NUM LOCK light is on.

  # RIGHT_ALT_PRESSED* = 0x0001
  # #The right ALT key is pressed.

  RIGHT_CTRL_PRESSED* = 0x0004
  #The right CTRL key is pressed.

  # SCROLLLOCK_ON* = 0x0040
  # #The SCROLL LOCK light is on.

  SHIFT_PRESSED* = 0x0010
  #The SHIFT key is pressed.

const
  # DOUBLE_CLICK* = 0x0002
  # MOUSE_HWHEELED* = 0x0008
  # MOUSE_MOVED* = 0x0001
  MOUSE_WHEELED* = 0x0004

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

proc enableMouse(hConsoleInput: Handle, prevMode: DWORD) =
  discard SetConsoleMode(hConsoleInput, ENABLE_WINDOW_INPUT or ENABLE_MOUSE_INPUT or ENABLE_EXTENDED_FLAGS or (prev_mode and ENABLE_QUICK_EDIT_MODE.bitnot()))

proc disableMouse(hConsoleInput: Handle, prevMode: DWORD) =
  discard SetConsoleMode(hConsoleInput,  prevMode)

when isMainModule:
  import os

  # illwillInit(fullscreen=true, mouse = true)
  # hideCursor()

  # var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

  var hConsoleInput: HANDLE = getStdHandle(STD_INPUT_HANDLE)
  var buffer: array[1024, INPUT_RECORD]
  var numberOfEventsRead: DWORD
  var prevMode: DWORD

  # if GetConsoleMode(hConsoleInput, addr prevMode) == 0:
    # echo getLastError()

  hConsoleInput.enableMouse(prevMode)

  var idx = 0
  # var lastMi: MouseInfo
  while true:
    # if PeekConsoleInputA(hConsoleInput, addr buffer, buffer.len.DWORD, addr numberOfEventsRead) == 0:
    #   echo getLastError()

    # if readConsoleInput(hConsoleInput, addr buffer, buffer.len.DWORD, addr numberOfEventsRead) == 0:
    #   echo getLastError()

    # if readConsoleInput(hConsoleInput, addr buffer, 1.DWORD, addr numberOfEventsRead) == 0:
    #   echo getLastError()

    discard PeekConsoleInputA(hConsoleInput, addr buffer, buffer.len.DWORD, addr numberOfEventsRead)
    var toRead = 0
    for elem in buffer[0..numberOfEventsRead.int-1]:
      # Filter for only MOUSE_EVENT
      toRead.inc()
      if elem.EventType == MOUSE_EVENT: break
    if toRead == 0: continue
    discard readConsoleInput(hConsoleInput, addr buffer, toRead.DWORD, addr numberOfEventsRead)
    assert toRead == numberOfEventsRead
    if buffer[numberOfEventsRead - 1].EventType == MOUSE_EVENT:
      echo buffer[numberOfEventsRead - 1]



  #     tb.write 0, 3, "MOUSE EVENT " & $idx

  #     var mi = MouseInfo()
  #     mi.x = elem.Event.MouseEvent.dwMousePosition.X
  #     mi.y = elem.Event.MouseEvent.dwMousePosition.Y

  #     case elem.Event.MouseEvent.dwButtonState
  #     of FROM_LEFT_1ST_BUTTON_PRESSED:
  #       mi.button = ButtonLeft
  #     of FROM_LEFT_2ND_BUTTON_PRESSED:
  #       mi.button = ButtonMiddle
  #     of RIGHTMOST_BUTTON_PRESSED:
  #       mi.button = ButtonRight
  #     else:
  #       mi.button = ButtonNone

  #     if lastMi.button == ButtonNone and mi.button != ButtonNone:
  #       mi.action = MouseButtonAction.Pressed
  #     else:
  #       mi.action = MouseButtonAction.Released

  #     # if bitand(elem.Event.MouseEvent.dwEventFlags, MOUSE_MOVED) == MOUSE_MOVED:
  #     #   mi.move = true
  #     # else:
  #     #   mi.move = false
  #     if lastMi.x != mi.x or lastMi.y != mi.y:
  #       mi.move = true
  #     else:
  #       mi.move = false

  #     if bitand(elem.Event.MouseEvent.dwEventFlags, MOUSE_WHEELED) == MOUSE_WHEELED:
  #       mi.scroll = true
  #       if elem.Event.MouseEvent.dwButtonState.testBit(31):
  #         mi.scrollDir = ScrollDirection.ScrollDown
  #       else:
  #         mi.scrollDir = ScrollDirection.ScrollUp
  #     else:
  #       mi.scroll = false


  #     if bitand(elem.Event.MouseEvent.dwControlKeyState, LEFT_CTRL_PRESSED) == LEFT_CTRL_PRESSED or
  #        bitand(elem.Event.MouseEvent.dwControlKeyState, RIGHT_CTRL_PRESSED) == RIGHT_CTRL_PRESSED:
  #       mi.ctrl = true
  #     else:
  #       mi.ctrl = false

  #     if bitand(elem.Event.MouseEvent.dwControlKeyState, SHIFT_PRESSED) == SHIFT_PRESSED:
  #       mi.shift = true
  #     else:
  #       mi.shift = false

  #     tb.write 0, 1, $lastMi

  #     lastMi = mi

  #     tb.write 0, 2, $mi
  #     tb.display()

  #   idx.inc
  #   if idx == 100: break
  #   sleep(50)

  hConsoleInput.disableMouse(prevMode)
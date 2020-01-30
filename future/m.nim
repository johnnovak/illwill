type
  INNER_C_UNION_m_17* {.bycopy.} = object {.union.}
    UnicodeChar*: WCHAR
    AsciiChar*: CHAR

  INNER_C_UNION_m_45* {.bycopy.} = object {.union.}
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
    uChar*: INNER_C_UNION_m_17
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
    Event*: INNER_C_UNION_m_45


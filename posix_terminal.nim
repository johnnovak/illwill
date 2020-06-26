import terminal
import os, bitops
import posix, tables, termios
import strutils, strformat

export terminalWidth
export terminalHeight
export terminalSize
export hideCursor
export showCursor

import common

export resetAttributes
export eraseScreen
export setCursorPos
export setCursorXPos

export getEnv

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

proc consoleInit*()
proc consoleDeinit*()

# Mouse
# https://de.wikipedia.org/wiki/ANSI-Escapesequenz
# https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Extended-coordinates
const
  CSI = 0x1B.chr & 0x5B.chr
  SET_BTN_EVENT_MOUSE = "1002"
  SET_ANY_EVENT_MOUSE = "1003"
  SET_SGR_EXT_MODE_MOUSE = "1006"
  # SET_URXVT_EXT_MODE_MOUSE = "1015"
  ENABLE = "h"
  DISABLE = "l"
  MouseTrackAny = fmt"{CSI}?{SET_BTN_EVENT_MOUSE}{ENABLE}{CSI}?{SET_ANY_EVENT_MOUSE}{ENABLE}{CSI}?{SET_SGR_EXT_MODE_MOUSE}{ENABLE}"
  DisableMouseTrackAny = fmt"{CSI}?{SET_BTN_EVENT_MOUSE}{DISABLE}{CSI}?{SET_ANY_EVENT_MOUSE}{DISABLE}{CSI}?{SET_SGR_EXT_MODE_MOUSE}{DISABLE}"

# Adapted from:
# https://ftp.gnu.org/old-gnu/Manuals/glibc-2.2.3/html_chapter/libc_24.html#SEC499
proc SIGTSTP_handler(sig: cint) {.noconv.} =
  signal(SIGTSTP, SIG_DFL)
  # XXX why don't the below 3 lines seem to have any effect?
  resetAttributes()
  showCursor()
  consoleDeinit()
  discard posix.raise(SIGTSTP)

proc SIGCONT_handler(sig: cint) {.noconv.} =
  signal(SIGCONT, SIGCONT_handler)
  signal(SIGTSTP, SIGTSTP_handler)

  gFullRedrawNextFrame = true
  consoleInit()
  hideCursor()

proc installSignalHandlers() =
  signal(SIGCONT, SIGCONT_handler)
  signal(SIGTSTP, SIGTSTP_handler)

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
  tv.tv_sec = Time(0)
  tv.tv_usec = 0

  var fds: TFdSet
  FD_ZERO(fds)
  FD_SET(STDIN_FILENO, fds)
  discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)
  return FD_ISSET(STDIN_FILENO, fds)

proc consoleInit*() =
  nonblock(true)
  installSignalHandlers()

proc consoleDeinit*() =
  nonblock(false)

# surely a 100 char buffer is more than enough; the longest
# keycode sequence I've seen was 6 chars
const KeySequenceMaxLen = 100

# global keycode buffer
var keyBuf: array[KeySequenceMaxLen, int]

let
  keySequences = {
    ord(common.Key.Up):        @["\eOA", "\e[A"],
    ord(common.Key.Down):      @["\eOB", "\e[B"],
    ord(common.Key.Right):     @["\eOC", "\e[C"],
    ord(common.Key.Left):      @["\eOD", "\e[D"],

    ord(common.Key.Home):      @["\e[1~", "\e[7~", "\eOH", "\e[H"],
    ord(common.Key.Insert):    @["\e[2~"],
    ord(common.Key.Delete):    @["\e[3~"],
    ord(common.Key.End):       @["\e[4~", "\e[8~", "\eOF", "\e[F"],
    ord(common.Key.PageUp):    @["\e[5~"],
    ord(common.Key.PageDown):  @["\e[6~"],

    ord(common.Key.F1):        @["\e[11~", "\eOP"],
    ord(common.Key.F2):        @["\e[12~", "\eOQ"],
    ord(common.Key.F3):        @["\e[13~", "\eOR"],
    ord(common.Key.F4):        @["\e[14~", "\eOS"],
    ord(common.Key.F5):        @["\e[15~"],
    ord(common.Key.F6):        @["\e[17~"],
    ord(common.Key.F7):        @["\e[18~"],
    ord(common.Key.F8):        @["\e[19~"],
    ord(common.Key.F9):        @["\e[20~"],
    ord(common.Key.F10):       @["\e[21~"],
    ord(common.Key.F11):       @["\e[23~"],
    ord(common.Key.F12):       @["\e[24~"],
  }.toTable

proc splitInputs(inp: openarray[int], max: Natural): seq[seq[int]] =
  ## splits the input buffer to extract mouse coordinates
  var parts: seq[seq[int]] = @[]
  var cur: seq[int] = @[]
  for ch in inp[CSI.len+1 .. max-1]:
    if ch == ord('M'):
      # Button press
      parts.add(cur)
      gMouseInfo.action = mbaPressed
      break
    elif ch == ord('m'):
      # Button release
      parts.add(cur)
      gMouseInfo.action = mbaReleased
      break
    elif ch != ord(';'):
      cur.add(ch)
    else:
      parts.add(cur)
      cur = @[]
  return parts

proc getPos(inp: seq[int]): int =
  var str = ""
  for ch in inp:
    str &= $(ch.chr)
  result = parseInt(str)

proc fillGlobalMouseInfo(keyBuf: array[KeySequenceMaxLen, int]) =
  let parts = splitInputs(keyBuf, keyBuf.len)
  gMouseInfo.x = parts[1].getPos() - 1
  gMouseInfo.y = parts[2].getPos() - 1
  let bitset = parts[0].getPos()
  gMouseInfo.ctrl = bitset.testBit(4)
  gMouseInfo.shift = bitset.testBit(2)
  gMouseInfo.move = bitset.testBit(5)
  case ((bitset.uint8 shl 6) shr 6).int
  of 0: gMouseInfo.button = MouseButton.mbLeft
  of 1: gMouseInfo.button = MouseButton.mbMiddle
  of 2: gMouseInfo.button = MouseButton.mbRight
  else:
    gMouseInfo.action = MouseButtonAction.mbaNone
    gMouseInfo.button = MouseButton.mbNone # Move sends 3, but we ignore
  gMouseInfo.scroll = bitset.testBit(6)
  if gMouseInfo.scroll:
    # on scroll button=3 is reported, but we want no button pressed
    gMouseInfo.button = MouseButton.mbNone
    if bitset.testBit(0): gMouseInfo.scrollDir = ScrollDirection.sdDown
    else: gMouseInfo.scrollDir = ScrollDirection.sdUp
  else:
    gMouseInfo.scrollDir = ScrollDirection.sdNone

proc parseKey(charsRead: int): common.Key =
  # Inspired by
  # https://github.com/mcandre/charm/blob/master/lib/charm.c
  var key = common.Key.None
  if charsRead == 1:
    let ch = keyBuf[0]
    case ch:
    of   9: key = common.Key.Tab
    of  10: key = common.Key.Enter
    of  27: key = common.Key.Escape
    of  32: key = common.Key.Space
    of 127: key = common.Key.Backspace
    of 0, 29, 30, 31: discard   # these have no Windows equivalents so
                                # we'll ignore them
    else:
      key = toKey(ch)

  elif charsRead > 3 and keyBuf[0] == 27 and keyBuf[1] == 91 and keyBuf[2] == 60: # TODO what are these :)
    fillGlobalMouseInfo(keyBuf)
    return common.Key.Mouse

  else:
    var inputSeq = ""
    for i in 0..<charsRead:
      inputSeq &= char(keyBuf[i])
    for keyCode, sequences in keySequences.pairs:
      for s in sequences:
        if s == inputSeq:
          key = toKey(keyCode)
  result = key

proc getKeyAsync*(): common.Key =
  var i = 0
  while kbhit() > 0 and i < KeySequenceMaxLen:
    var ret = read(0, keyBuf[i].addr, 1)
    if ret > 0:
      i += 1
    else:
      break
  if i == 0:  # nothing read
    result = common.Key.None
  else:
    result = parseKey(i)

template put*(s: string) = stdout.write s

proc enableMouse*() =
  stdout.write(MouseTrackAny)
  stdout.flushFile()

proc disableMouse*() =
  stdout.write(DisableMouseTrackAny)
  stdout.flushFile()

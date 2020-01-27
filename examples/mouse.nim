# https://de.wikipedia.org/wiki/ANSI-Escapesequenz
# https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Extended-coordinates
import os, strutils
import illwill

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

illwillInit(fullscreen=true)
setControlCHook(exitProc)
hideCursor()


import strformat
const 
  CSI = 0x1B.chr & 0x5B.chr
  SET_BTN_EVENT_MOUSE = "1002"
  SET_ANY_EVENT_MOUSE = "1003"
  SET_SGR_EXT_MODE_MOUSE = "1006"
  # SET_SGR_EXT_MODE_MOUSE = "1015"
  ENABLE = "h"
  DISABLE = "l"

  mouseTrackButtonPress = fmt"{CSI}?{SET_BTN_EVENT_MOUSE}{ENABLE}{CSI}?{SET_SGR_EXT_MODE_MOUSE}{ENABLE}"
  # mouseTrackButtonPress1015 = fmt"{CSI}?{SET_BTN_EVENT_MOUSE}{ENABLE}{CSI}?{SET_SGR_EXT_MODE_MOUSE}{ENABLE}"
  mouseTrackAnyEvent = fmt"{CSI}?{SET_ANY_EVENT_MOUSE}{ENABLE}{CSI}?{SET_SGR_EXT_MODE_MOUSE}{ENABLE}"
# /* DECSET arguments for turning on mouse reporting modes */
#define SET_X10_MOUSE               9
#define SET_VT200_MOUSE             1000
#define SET_VT200_HIGHLIGHT_MOUSE   1001
#define SET_BTN_EVENT_MOUSE         1002
#define SET_ANY_EVENT_MOUSE         1003

#if OPT_FOCUS_EVENT
#define SET_FOCUS_EVENT_MOUSE       1004 /* can be combined with above */
#endif

# /* Extend mouse tracking for terminals wider(taller) than 223 cols(rows) */
#define SET_EXT_MODE_MOUSE          1005 /* compatible with above */
#define SET_SGR_EXT_MODE_MOUSE      1006
#define SET_URXVT_EXT_MODE_MOUSE    1015

#define SET_ALTERNATE_SCROLL        1007 /* wheel mouse may send cursor-keys */

#define SET_BUTTON1_MOVE_POINT      2001 /* click1 emit Esc seq to move point*/
#define SET_BUTTON2_MOVE_POINT      2002 /* press2 emit Esc seq to move point*/
#define SET_DBUTTON3_DELETE         2003 /* Double click-3 deletes */
#define SET_PASTE_IN_BRACKET        2004 /* Surround paste by escapes */
#define SET_PASTE_QUOTE             2005 /* Quote each char during paste */
#define SET_PASTE_LITERAL_NL        2006 /* Paste "\n" as C-j */


var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

echo mouseTrackButtonPress
# echo mouseTrackAnyEvent

# echo "\e[?1003h\e[?1006h" #! mouse enable + mode # track also mouse motion 
# echo "\e[?1002h\e[?1006h" #! mouse enable + mode # track only on button press # cell motion tracking
# echo "\e[?1002h\e[?1015h" #! mouse enable + mode # track only on button press # cell motion tracking


while true:
  var key = getKey()
  case key
  of Key.None: discard
  of Key.Escape, Key.Q: exitProc()
  of Key.Mouse:
    let coords = getMouse()
    # echo coords
    if coords.action == MouseButtonAction.Pressed:
      tb.write coords.x, coords.y, "#"
    else:
      tb.write coords.x, coords.y, "^"
  else:
    echo key
    discard

  tb.display()
  sleep(20)
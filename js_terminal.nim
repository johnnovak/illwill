import
  unicode,
  tables
import dom except Style

import
  common

let
  fgColorMapBright = {
      $fgNone: "white",
      $fgBlack: "black",
      $fgRed: "red",
      $fgGreen: "lime",
      $fgYellow: "yellow",
      $fgBlue: "lightskyblue",
      $fgMagenta: "magenta",
      $fgCyan: "cyan",
      $fgWhite: "white",
      $bgNone: "black",
      $bgBlack: "black",
      $bgRed: "red",
      $bgGreen: "lime",
      $bgYellow: "yellow",
      $bgBlue: "lightskyblue",
      $bgMagenta: "magenta",
      $bgCyan: "cyan",
      $bgWhite: "white"
    }.toTable
  fgColorMapDim = {
      $fgNone: "gray",
      $fgBlack: "black",
      $fgRed: "crimson",
      $fgGreen: "green",
      $fgYellow: "goldenrod",
      $fgBlue: "blue",
      $fgMagenta: "mediumpurple",
      $fgCyan: "aqua",
      $fgWhite: "gray",
      $bgNone: "black",
      $bgBlack: "black",
      $bgRed: "crimson",
      $bgGreen: "green",
      $bgYellow: "goldenrod",
      $bgBlue: "blue",
      $bgMagenta: "mediumpurple",
      $bgCyan: "aqua",
      $bgWhite: "gray"
    }.toTable
  bgColorMap = {
      $bgNone: "black",
      $bgBlack: "black",
      $bgRed: "red",
      $bgGreen: "lime",
      $bgYellow: "yellow",
      $bgBlue: "lightskyblue",
      $bgMagenta: "magenta",
      $bgCyan: "cyan",
      $bgWhite: "white",
      $fgNone: "black",
      $fgBlack: "black",
      $fgRed: "red",
      $fgGreen: "lime",
      $fgYellow: "yellow",
      $fgBlue: "lightskyblue",
      $fgMagenta: "magenta",
      $fgCyan: "cyan",
      $fgWhite: "white"
    }.toTable


var
  preTag: Element
  preTagId: cstring
  preTagRowSize: int = 24
  preTagColumnSize: int = 80
  lastKey: cstring = ""

var
  cursorX = 0
  cursorY = 0
  cursorOn = false
  cursorBlockVisible = false 

var
  globalTimer*: ref Interval
  cursorTimer*: ref Interval


proc setAttribs*(c: TerminalChar) =
  discard


proc resetAttributes*() =
  discard


proc envSetForegroundColor*(bg: int) =
  discard


proc envSetBackgroundColor*(bg: int) =
  discard


proc envSetStyle*(style: set[common.Style]) =
  discard


proc terminalWidth*(): int =
  result = preTagColumnSize


proc terminalHeight*(): int =
  result = preTagRowSize


proc terminalSize*(): tuple[w, h: int] =
  result.w = terminalWidth()
  result.h = terminalHeight()


proc showCursor*() =
  cursorOn = true
  cursorBlockVisible = true


proc hideCursor*() =
  cursorOn = false
  cursorBlockVisible = false


proc setCursorPos*(x, y: Natural) =
  cursorX = x
  cursorY = y


proc setCursorXPos*(x: Natural) = 
  cursorX = x


proc enableMouse*() =
  discard


proc disableMouse*() =
  discard


proc genStartSpan(fg: ForegroundColor, bg: BackgroundColor, st: set[Style]): string =
  result = "<span style=\""
  #
  # foreground
  #
  result &= "color: "
  if styleHidden in st:
    result &= "transparent;"
  else:
    if styleReverse in st:
      if styleDim in st:
        result &= fgColorMapDim[$bg]
      else:
        result &= fgColorMapBright[$bg]
      result &= ";"
    else:
      if styleDim in st:
        result &= fgColorMapDim[$fg]
      else:
        result &= fgColorMapBright[$fg]
      result &= ";"
  #
  # background
  #
  result &= " background-color: "
  if styleReverse in st:
    result &= bgColorMap[$fg]
    result &= ";"
  else:
    result &= bgColorMap[$bg]
    result &= ";"
  #
  # font styles
  #
  if styleItalic in st:
    result &= " font-style: italic;"
  if styleUnderscore in st:
    if styleStrikethrough in st:
      result &= " text-decoration: underline line-through;"
    else:
      result &= " text-decoration: underline;"
  elif styleStrikethrough in st:
    result &= " text-decoration: line-through;"
  #
  result &= "\""  # 'style=' ends
  #
  # blinking classes
  #
  if styleBlink in st:
    if styleBlinkRapid in st:
      result &= " class=\"blink blinkrapid\""
    else:
      result &= " class=\"blink\""
  elif styleBlinkRapid in st:
    result &= " class=\"blinkrapid\""
  #
  result &= ">"


proc genRowHtml(tb: TerminalBuffer, row: int): string =
  var fg = tb[0, row].fg
  var bg = tb[0, row].bg
  var st = tb[0, row].style
  result = genStartSpan(fg, bg, st)
  for col in 0 ..< tb.width:
    let c = tb[col, row]
    if (c.fg != fg) or (c.bg != bg) or (c.style != st):
      result &= "</span>"
      result &= genStartSpan(c.fg, c.bg, c.style)
      fg = c.fg
      bg = c.bg
      st = c.style
    if cursorBlockVisible and (row == cursorY) and (col == cursorX):
      result &= "█"
    else:
      result &= $c.ch
  result &= "</span>"


proc applyTbToPre(tb: TerminalBuffer) =
  if preTag.isNil:
    # echo "(attp) not loaded yet"
    return
  setCursorPos(tb.currX, tb.currY)
  var newHtml = ""
  for row in 0 ..< tb.height:
    newHtml &= tb.genRowHtml(row)
    if row < (tb.height - 1):
      newHtml &= "\n"
  preTag.innerHtml = newHtml.cstring


proc eraseScreen*() =
  discard


proc put*(tb: TerminalBuffer) = 
  applyTbToPre(tb)


proc setControlCHook*(hook: proc () {.noconv.}) =
  discard


proc unsetControlCHook*() =
  discard


proc onkeydown(ev: Event) =
  # echo $ev.`type`
  var temp = cast[KeyboardEvent](ev)
  lastKey = temp.key


let jsKeyMap = {
  "ArrowUp": Key.Up,
  "ArrowDown": Key.Down,
  "ArrowLeft": Key.Left,
  "ArrowRight": Key.Right
}.toTable

proc getKeyAsync*(): Key =
  result = Key.None
  let rawKey = $lastKey
  lastKey = "".cstring
  case len(rawKey):
  of 0:
    discard
  of 1:
    var asciiInt = rawKey[0].ord
    result = asciiInt.toKey()
  else:
    for keyItem in Key:
      if $keyItem == rawKey:
        result = keyItem
        break
    if result == Key.None:
      if jsKeyMap.hasKey(rawKey):
        result = jsKeyMap[rawKey]


proc dummyInterval() = 
  discard


proc cursorBlinker() =
  if cursorOn:
    cursorBlockVisible = not cursorBlockVisible
  else:
    cursorBlockVisible = false


proc consoleInit*() =
  window.addEventListener(
    "keydown".cstring,
    onkeydown,
    false
  )
  globalTimer = window.setInterval(dummyInterval, 6000)
  globalTimer = window.setInterval(cursorBlinker, 800)
  if not preTag.isNil:
    preTag.disabled = false


proc consoleDeInit*() =
  window.clearInterval(globalTimer)
  window.clearInterval(cursorTimer)
  window.removeEventListener(
    "keydown".cstring, 
    onkeydown
  )
  if preTag.isNil:
    echo "cdi not loaded yet"
    return
  preTag.disabled = true


template timerLoop*(msDelay: int, content: untyped): untyped =
  globalTimer = window.setInterval(
    proc() =
      content
    , msDelay)


proc illwillOnLoad*(domId: cstring, cols, rows: int) {.exportc.} =
  preTagId = domId
  preTag = document.getElementById(domId)
  preTagColumnSize = cols
  preTagRowSize = rows
  if preTag.isNil:
    echo "ERROR: illwillOnLoad cannot find the id of \"" & $domId & "\""
    return

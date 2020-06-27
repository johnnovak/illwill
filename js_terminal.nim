import
  unicode,
  dom,
  tables

import
  common

let
  fgColorMap = {
      $fgNone: "white",
      $fgBlack: "black",
      $fgRed: "red",
      $fgGreen: "green",
      $fgYellow: "yellow",
      $fgBlue: "blue",
      $fgMagenta: "magenta",
      $fgCyan: "cyan",
      $fgWhite: "white"
    }.toTable
  bgColorMap = {
      $bgNone: "black",
      $bgBlack: "black",
      $bgRed: "red",
      $bgGreen: "green",
      $bgYellow: "yellow",
      $bgBlue: "blue",
      $bgMagenta: "magenta",
      $bgCyan: "cyan",
      $bgWhite: "white"
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

var
  globalTimer*: ref Interval


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
  result = preTagColumnSize - 1


proc terminalHeight*(): int =
  result = preTagRowSize - 1


proc terminalSize*(): tuple[w, h: int] =
  result.w = terminalWidth()
  result.h = terminalHeight()


proc showCursor*() =
  discard


proc hideCursor*() =
  discard


proc setCursorPos*(x, y: Natural) =
  cursorX = x
  cursorY = y


proc setCursorXPos*(x: Natural) = 
  cursorX = x


proc enableMouse*() =
  discard


proc disableMouse*() =
  discard


proc genStartSpan(fg: ForegroundColor, bg: BackgroundColor): string =
  result = "<span style=\"color: "
  result &= fgColorMap[$fg]
  result &= "; background-color: "
  result &= bgColorMap[$bg]
  result &= ";\">"


proc genRowHtml(tb: TerminalBuffer, row: int): string =
  var fg = tb[0, row].fg
  var bg = tb[0, row].bg
  result = genStartSpan(fg, bg)
  for col in 0 ..< tb.width:
    let c = tb[col, row]
    if (c.fg != fg) or (c.bg != bg):
      result &= "</span>"
      result &= genStartSpan(c.fg, c.bg)
      fg = c.fg
      bg = c.bg
    result &= $c.ch
  result &= "</span>"


proc applyTbToPre(tb: TerminalBuffer) =
  if preTag.isNil:
    echo "not loaded yet"
    return
  var newHtml = ""
  for row in 0 ..< tb.height:
    newHtml &= tb.genRowHtml(row)
    if row < (tb.height - 1):
      newHtml &= "\n"
  preTag.innerHtml = newHtml.cstring


proc eraseScreen*() =
  # TODO
  discard
  # if not preTag.isNil:
  #   cursorColumn = 0
  #   cursorRow = 0
  #   resetScreenRows()
  #   splashIntoPreTag()


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


proc consoleInit*() =
  window.addEventListener(
    "keydown".cstring,
    onkeydown,
    false
  )
  globalTimer = window.setInterval(dummyInterval, 6000)
  if not preTag.isNil:
    preTag.disabled = false


proc consoleDeInit*() =
  window.clearInterval(globalTimer)
  window.removeEventListener(
    "keydown".cstring, 
    onkeydown
  )
  if preTag.isNil:
    echo "not loaded yet"
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
  if preTag.isNil:
    echo "ERROR: illwillOnLoad cannot find the id of \"" & $domId & "\""
    return
  preTagColumnSize = cols
  preTagRowSize = rows

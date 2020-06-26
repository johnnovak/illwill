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
  discard


proc setCursorXPos*(x: Natural) = 
  discard


proc enableMouse*() =
  discard


proc disableMouse*() =
  discard


proc eraseScreen*() =
  # TODO
  discard
  # if not preTag.isNil:
  #   cursorColumn = 0
  #   cursorRow = 0
  #   resetScreenRows()
  #   splashIntoPreTag()


proc put*(s: string) = 
  discard


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
  # globalTimer = window.setInterval(dummyInterval, 6000)
  # if not preTag.isNil:
  #   splashIntoPreTag()
  #   preTag.disabled = false


proc consoleDeInit*() =
  # window.clearInterval(globalTimer)
  window.removeEventListener(
    "keydown".cstring, 
    onkeydown
  )
  # if preTag.isNil:
  #   echo "not loaded yet"
  #   return
  # preTag.disabled = true


var globalTimer*: ref Interval

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

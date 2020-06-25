import
  unicode,
  dom,
  tables

export dom except Style

import
  definitions

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
  stdout*: dom.File  # this has no real meaning in the JS context, but needed for compatibility
  stderr*: dom.File  # this has no real meaning in the JS context, but needed for compatibility

var
  preTag: Element
  preTagId: cstring
  preTagRowSize: int = 24
  preTagColumnSize: int = 80
  cursorRow: int = 0
  cursorColumn: int = 0
  cursorFgColor: ForegroundColor = fgNone
  cursorBgColor: BackgroundColor = bgNone

  screenRows: array[901, seq[Rune]]
  previousScreenRows: array[901, seq[Rune]]

  screenFgColors: array[901, seq[ForegroundColor]]
  screenBgColors: array[901, seq[BackgroundColor]]

var lastKey*: cstring = ""
var globalTimer*: ref Interval


proc setRowSize(newSize: int) =
  if newSize < 2:
    preTagRowSize = 2
  elif newSize > 900:
    preTagRowSize = 900
  else:
    preTagRowSize = newSize


proc resetScreenRows() =
  for row in 0 .. preTagRowSize:  # this includes one row past the end
    screenRows[row] = @[]
    screenFgColors[row] = @[]
    screenBgColors[row] = @[]
    for col in 0 ..< preTagColumnSize:
      screenRows[row].add " ".runeAt(0)
      screenFgColors[row].add fgNone
      screenBgColors[row].add bgNone

resetScreenRows()  # needed during startup


proc detectDiff(): bool =
  result = false
  for row in 0 ..< preTagRowSize:
    if $screenRows[row] != $previousScreenRows[row]:
      result = true
      previousScreenRows[row] = screenRows[row]


proc genStartSpan(fg: ForegroundColor, bg: BackgroundColor): string =
  result = "<span style=\"color: "
  result &= fgColorMap[$fg]
  result &= "; background-color: "
  result &= bgColorMap[$bg]
  result &= ";\">"


proc genRowHtml(rowIndex: int): string =
  var fg = fgNone
  var bg = bgNone
  result = genStartSpan(fg, bg)
  for col in 0 ..< screenRows[rowIndex].len:
    let newr = screenRows[rowIndex][col]
    let newf = screenFgColors[rowIndex][col]
    let newb = screenBgColors[rowIndex][col]
    if (newf != fg) or (newb != bg):
      result &= "</span>"
      result &= genStartSpan(newf, newb)
      fg = newf
      bg = newb
    result &= $newr
  result &= "</span>"


proc splashIntoPreTag() =
  if detectDiff():
    var newHtml = ""
    for row in 0 ..< preTagRowSize:
      newHtml &= row.genRowHtml
      if row < (preTagRowSize - 1):
        newHtml &= "\n"
    if preTag.isNil:
      echo "not loaded yet"
      return
    preTag.innerHtml = newHtml.cstring


proc eraseScreen*() =
  if not preTag.isNil:
    cursorColumn = 0
    cursorRow = 0
    resetScreenRows()
    splashIntoPreTag()


proc onkeydown(ev: Event) =
  # echo $ev.`type`
  var temp = cast[KeyboardEvent](ev)
  lastKey = temp.key


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
    splashIntoPreTag()
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


proc setPos*(x, y: Natural) =
  cursorColumn = x
  cursorRow = y
  if cursorColumn > 79:
    echo "sp col too far " & $cursorColumn 
  if cursorRow > 23:
    echo "sp row too far " & $cursorRow


proc setXPos*(x: Natural) =
  cursorColumn = x 


proc handleWrap() =
  if cursorColumn > preTagColumnSize:
    cursorColumn = 0
    cursorRow += 1
    if cursorRow > preTagRowSize:
      for index in 0 ..< preTagRowSize:
        screenRows[index] = screenRows[index + 1]
      screenRows[preTagRowSize - 1] = @[]
      cursorRow = preTagRowSize - 1


proc putChar(ch: Rune) = 
  screenRows[cursorRow][cursorColumn] = ch
  screenFgColors[cursorRow][cursorColumn] = cursorFgColor
  screenBgColors[cursorRow][cursorColumn] = cursorBgColor
  cursorColumn += 1
  handleWrap()


proc put*(s: string) = 
  for ch in s.runes:
    putChar(ch)
  splashIntoPreTag()


proc setAttribs*(c: TerminalChar) =
  cursorFgColor = c.fg
  cursorBgColor = c.bg


proc resetAttributes*() =
  cursorFgColor = fgNone
  cursorBgColor = bgNone


proc showCursor*() =
  discard


proc hideCursor*() =
  discard


proc setCursorPos*(x, y: int) =
  discard


proc terminalWidth*(): int =
  result = preTagColumnSize - 1


proc terminalHeight*(): int =
  result = preTagRowSize - 1


proc terminalSize*(): tuple[w, h: int] =
  result.w = terminalWidth()
  result.h = terminalHeight()


proc setControlCHook*(hook: proc () {.noconv.}) =
  discard


proc unsetControlCHook*() =
  discard


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
  setRowSize(rows)
  cursorColumn = 0
  cursorRow = 0
  consoleInit()

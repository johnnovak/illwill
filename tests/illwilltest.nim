import os
import illwill

proc keyName(key: int): string =
  case key:
  of keyCtrlA: result = "keyCtrlA"
  of keyCtrlB: result = "keyCtrlB"
  of keyCtrlD: result = "keyCtrlD"
  of keyCtrlE: result = "keyCtrlE"
  of keyCtrlF: result = "keyCtrlF"
  of keyCtrlG: result = "keyCtrlG"
  of keyCtrlH: result = "keyCtrlH"
  of keyCtrlJ: result = "keyCtrlJ"
  of keyCtrlK: result = "keyCtrlK"
  of keyCtrlL: result = "keyCtrlL"
  of keyCtrlN: result = "keyCtrlN"
  of keyCtrlO: result = "keyCtrlO"
  of keyCtrlP: result = "keyCtrlP"
  of keyCtrlQ: result = "keyCtrlQ"
  of keyCtrlR: result = "keyCtrlR"
  of keyCtrlS: result = "keyCtrlS"
  of keyCtrlT: result = "keyCtrlT"
  of keyCtrlU: result = "keyCtrlU"
  of keyCtrlV: result = "keyCtrlV"
  of keyCtrlW: result = "keyCtrlW"
  of keyCtrlX: result = "keyCtrlX"
  of keyCtrlY: result = "keyCtrlY"
  of keyCtrlZ: result = "keyCtrlZ"

  of keyCtrlBackslash:    result = "keyCtrlBackslash"
  of keyCtrlCloseBracket: result = "keyCtrlCloseBracket"

  of keyBackspace:  result = "keyBackspace"
  of keyTab:        result = "keyTab"
  of keyEnter:      result = "keyEnter"
  of keyEscape:     result = "keyEscape"
  of keySpace:      result = "keySpace"

  of keyUp:         result = "keyUp"
  of keyDown:       result = "keyDown"
  of keyRight:      result = "keyRight"
  of keyLeft:       result = "keyLeft"

  of keyHome:       result = "keyHome"
  of keyInsert:     result = "keyInsert"
  of keyDelete:     result = "keyDelete"
  of keyEnd:        result = "keyEnd"
  of keyPageUp:     result = "keyPageUp"
  of keyPageDown:   result = "keyPageDown"

  of keyF1:  result = "keyF1"
  of keyF2:  result = "keyF2"
  of keyF3:  result = "keyF3"
  of keyF4:  result = "keyF4"
  of keyF5:  result = "keyF5"
  of keyF6:  result = "keyF6"
  of keyF7:  result = "keyF7"
  of keyF8:  result = "keyF8"
  of keyF9:  result = "keyF9"
  of keyF10: result = "keyF10"
  of keyF11: result = "keyF11"
  of keyF12: result = "keyF12"
  else:
    result = $cast[char](key)


consoleInit()

while true:
  var key = getKey()
  if key != keyNone:
    echo keyName(key)
  else:
    sleep(1)

consoleDeinit()


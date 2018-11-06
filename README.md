# illwill

## Installation

```
nimble install illwill
```

## Usage


```nimrod
import illwill
import os

illwillInit(fullscreen=true)

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
tb.display()
echo "Press Q, Esc or Ctrl-C to quit"

while true:
  var key = getKey()
  case key
  of Key.None: discard
  of Key.Escape, Key.Q:
    illwillDeinit()
    quit(0)
  else:
    echo key

  sleep(20)

illwillDeinit()

```

## Credits


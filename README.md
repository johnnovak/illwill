# illwill

## Installation

```
nimble install illwill
```

## Usage


```nimrod
import illwill

illwillInit(fullscreen=true)

var cb = newConsoleBuffer(terminalWidth(), terminalHeight())

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


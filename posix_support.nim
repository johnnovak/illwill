import
  os

import
  definitions

template timerLoop*(msDelay: int, content: untyped): untyped =
  while true:
    content
    sleep(msDelay)

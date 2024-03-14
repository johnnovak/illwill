import unittest

when not defined(windows):

  type
    MockStdin = ref object
      buf: string
      off = 0

  proc kbhit(mock: MockStdin): cint =
    return cint(mock.off <= mock.buf.high)

  proc read(mock: MockStdin, p: ptr char, sz: int): int =
    assert sz == 1
    if mock.off <= mock.buf.high:
      p[] = mock.buf[mock.off]
      inc mock.off
      return sz
    else:
      return 0

  include illwill

  test "escape":
    let mock = MockStdin(buf: "\e")
    check parseStdin(mock) == Key.Escape

  test "f10":
    let mock = MockStdin(buf: "\e[21~")
    check parseStdin(mock) == Key.F10

  test "wrong":
    let mock = MockStdin(buf: "\e[91~")
    check parseStdin(mock) == Key.None
    check parseStdin(mock) == Key.One
    check parseStdin(mock) == Key.Tilde

  test "not full":
    let mock = MockStdin(buf: "\e[21")
    check parseStdin(mock) == Key.None

  test "all keySequences":
    var buf = ""
    var exp: seq[Key]
    for k, v in keySequences:
      for s in v:
        exp.add Key(k)
        buf.add s
      exp.add Key.Space
      buf.add " "
    exp.add Key.Escape

    let mock = MockStdin(buf: buf)
    var i = 0
    while kbhit(mock) > 0:
      check parseStdin(mock) == exp[i]
      inc i

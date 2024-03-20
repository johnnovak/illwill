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

  const
    keySequences = {
      ord(Key.Up):        @["\eOA", "\e[A"],
      ord(Key.Down):      @["\eOB", "\e[B"],
      ord(Key.Right):     @["\eOC", "\e[C"],
      ord(Key.Left):      @["\eOD", "\e[D"],

      ord(Key.Home):      @["\e[1~", "\e[7~", "\eOH", "\e[H"],
      ord(Key.Insert):    @["\e[2~"],
      ord(Key.Delete):    @["\e[3~"],
      ord(Key.End):       @["\e[4~", "\e[8~", "\eOF", "\e[F"],
      ord(Key.PageUp):    @["\e[5~"],
      ord(Key.PageDown):  @["\e[6~"],

      ord(Key.F1):        @["\e[11~", "\eOP"],
      ord(Key.F2):        @["\e[12~", "\eOQ"],
      ord(Key.F3):        @["\e[13~", "\eOR"],
      ord(Key.F4):        @["\e[14~", "\eOS"],
      ord(Key.F5):        @["\e[15~"],
      ord(Key.F6):        @["\e[17~"],
      ord(Key.F7):        @["\e[18~"],
      ord(Key.F8):        @["\e[19~"],
      ord(Key.F9):        @["\e[20~"],
      ord(Key.F10):       @["\e[21~"],
      ord(Key.F11):       @["\e[23~"],
      ord(Key.F12):       @["\e[24~"],
    }

  test "special keys":
    check parseStdin(MockStdin(buf: "\e")) == Key.Escape
    check parseStdin(MockStdin(buf: "\t")) == Key.Tab
    check parseStdin(MockStdin(buf: "\n")) == Key.Enter
    check parseStdin(MockStdin(buf: "\b")) == Key.Backspace
    check parseStdin(MockStdin(buf: " ")) == Key.Space

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
    for (k, v) in keySequences:
      for s in v:
        exp.add toKey(k)
        buf.add s
      exp.add Key.Space
      buf.add " "
    exp.add Key.Escape

    let mock = MockStdin(buf: buf)
    var i = 0
    while kbhit(mock) > 0:
      check parseStdin(mock) == exp[i]
      inc i

import illwill
import strutils
import random


illwillInit(fullscreen=false)
hideCursor()

const
  EMPTY = 0
  COMPUTER = 90
  HUMAN = 91
  TIE = 92
  ROW_OFFSET = 7
  ROW_SIZE = 4
  COLUMN_OFFSET = 32
  COLUMN_SIZE = 6
  ROW_MARGIN = 2
  COLUMN_MARGIN = 3

type
  GameStates = enum
    gsGameInit,
    gsPrepareForUser,
    gsWaitingOnUser,
    gsComputerChoice,
    gsStartEnd,
    gsEnd
  TicTacToe = object
    board: array[9, int]
    turn: int
    winner: int
    state: GameStates


proc newGame(game: var TicTacToe) =
  for i in 0 ..< 9:
    game.board[i] = EMPTY
  game.turn = HUMAN
  game.winner = EMPTY
  game.state = gsPrepareForUser


proc done(game: TicTacToe): bool =
  result = (game.winner != EMPTY)


proc newTurn(game: var TicTacToe) = 
  if game.turn == HUMAN:
    game.turn = COMPUTER
  else:
    game.turn = HUMAN


proc displayPlayer(tb: var TerminalBuffer, c: int, pos: int) = 
  if c == EMPTY:
    tb.write(fgNone, bgNone, styleDim, $pos)
  elif c == HUMAN:
    tb.write(fgWhite, bgBlue, "X")
  else:
    tb.write(fgWhite, bgRed, "O")
  tb.write(fgNone, bgNone, resetStyle)


proc displayGame(tb: var TerminalBuffer, game: TicTacToe) =
  for row in 0 .. 2:
    for column in 0 .. 2:
      let scrnCol = COLUMN_OFFSET + column * COLUMN_SIZE
      let scrnRow = ROW_OFFSET + row * ROW_SIZE
      tb.write(scrnCol, scrnRow, resetStyle, fgGreen)
      tb.drawRect(
        scrnCol - COLUMN_MARGIN, scrnRow - ROW_MARGIN,
        scrnCol + COLUMN_MARGIN, scrnRow + ROW_MARGIN
      )
      let offset = (row * 3) + column
      tb.displayPlayer(game.board[offset], offset + 1)


proc getWinner(game: TicTacToe): int =
  const
    WINNING_COMBOS = [
      [0, 1, 2], # across top
      [3, 4, 5], # across middle
      [6, 7, 8], # across bottom
      [0, 3, 6], # down on left
      [1, 4, 7], # down on middle
      [2, 5, 8], # down on right
      [0, 4, 8], # diagonal
      [2, 4, 6]  # the other diagonal
    ]
  result = EMPTY
  var humanCnt = 0
  var computerCnt = 0
  for combo in WINNING_COMBOS:
    humanCnt = 0
    computerCnt = 0
    for square in combo:
      if game.board[square] == HUMAN:
        humanCnt += 1
      elif game.board[square] == COMPUTER:
        computerCnt += 1
    if humanCnt == 3:
      result = HUMAN
      break
    if computerCnt == 3:
      result = COMPUTER
      break
  if result == EMPTY: # if still no winner, are we out of moves?
    var emptyCnt = 0
    for square in game.board:
      if square == EMPTY:
        emptyCnt += 1
        break
    if emptyCnt == 0:
      result = TIE


proc play(game: var TicTacToe, choice: int): string =
  let actualChoice = choice - 1
  if game.board[actualChoice] == EMPTY:
    game.board[actualChoice] = game.turn
    if game.getWinner() == EMPTY:
      result = "good"
    else:
      result = "done"
    game.newTurn()
  else:
    result = $choice & " is not empty."


randomize()

proc makeComputerChoose(game: TicTacToe): int =
  var choices = [0, 0, 0, 0, 0, 0, 0, 0, 0]
  var index = 0
  for spot in 0 .. 8:
    if game.board[spot] == EMPTY:
      choices[index] = spot
      index += 1
  let indexIndex = rand(index - 1)
  result = choices[indexIndex] + 1


var messages: array[8, string] = ["", "", "", "", "", "", "", ""]

proc msgBox(tb: var TerminalBuffer, newMsg: string) =
  for i in 0 .. 6:
    messages[i] = messages[i + 1]
  messages[7] = newMsg
  tb.write(fgNone, bgNone, resetStyle)
  tb.drawRect(52, ROW_OFFSET, 79, ROW_OFFSET + 9)
  for i in 0 .. 7:
    tb.write(54, ROW_OFFSET + 1 + i, "                         ")
    tb.write(54, ROW_OFFSET + 1 + i, messages[i])


var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

when not defined(js):
  proc exitProc() {.noconv.} =
    illwillDeinit()
    quit(0)
  setControlCHook(exitProc)

tb.write(31, 0, fgYellow, "BAD TIC TAC TOE")
tb.write(26, 1, "(AKA NAUGHTS AND CROSSES)")
tb.write(0, 3, fgGreen, styleItalic)
tb.write("Regular tic tac toe game rules, but the computer just foolishly moves at random.")
tb.write(0, 4, "You play as X.")

var game = TicTacToe(state: gsGameInit)

timerLoop(20):
  case game.state:
  of gsGameInit:
    game.newGame()
    game.state = gsPrepareForUser
    msgbox(tb, "Game started.")
  of gsPrepareForUser:
    tb.displayGame(game)
    tb.write(4, 21, "Choose a square (or 'pass' to skip or 'new' to start over.):")
    tb.write(65, 21, bgBlue, "    ")
    tb.startInputLine(65, 21, "", 4)
    game.state = gsWaitingOnUser
    tb.display()
  of gsWaitingOnUser:
    if tb.inputLineReady():
      var answer = getInputLineText()
      if answer == "":
        game.state = gsPrepareForUser
      elif ["1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(answer):
        let choice = parseInt(answer)
        msgbox(tb, "You chose " & answer & ".")
        let errMsg = game.play(choice)
        if errMsg == "good":
          msgBox(tb, "Computer is thinking...")
          game.state = gsComputerChoice
        elif errMsg == "done":
          msgBox(tb, "Game is over.")
          game.state = gsStartEnd
        else:
          msgbox(tb, errMsg)
          game.state = gsPrepareForUser
      elif answer == "new":
        msgbox(tb, "Resetting...")
        game.state = gsGameInit
      elif answer == "pass":
        msgbox(tb, "Skipping your turn.")
        msgBox(tb, "Computer is thinking...")
        game.newTurn()
        game.state = gsComputerChoice
      else:
        msgbox(tb, "Not a valid choice.")
        game.state = gsPrepareForUser
      tb.display()
  of gsComputerChoice:
    let choice = game.makeComputerChoose()
    msgBox(tb, "Computer chose " & $choice & ".")
    let errMsg = game.play(choice)
    tb.displayGame(game)
    if errMsg == "done":
      msgBox(tb, "Game is over.")
      game.state = gsStartEnd
    else:
      game.state = gsPrepareForUser
    tb.display()
  of gsStartEnd:
    tb.displayGame(game)
    let winner = game.getWinner()
    if winner == HUMAN:
      msgBox(tb, "You won!!")
    elif winner == COMPUTER:
      msgBox(tb, "Uh oh. Computer won.")
    else:
      msgBox(tb, "A tie!!")
    tb.write(4, 21, fgYellow, styleUnderscore, "Game over. Well played!")
    tb.write(fgNone, resetStyle, " Enter the word 'new' to play again.:")
    tb.write(65, 21, bgBlue, "    ")
    tb.startInputLine(65, 21, "", 4)
    tb.display()
    game.state = gsEnd
  of gsEnd:
    if tb.inputLineReady():
      var answer = getInputLineText()
      if answer == "new":
        game.state = gsGameInit
      else:
        msgBox(tb, "Unknown command.")
        tb.write(65, 21, bgBlue, "    ")
        tb.startInputLine(65, 21, "", 4)
        tb.display()

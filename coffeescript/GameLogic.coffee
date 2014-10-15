define ['AI', 'GameState', 'GameStates'], (AI, GameState, GameStates) ->
  TOTAL_CELLS = 4**3
  moves = []

  isValidMove = (move) ->
    move? and move not in moves

  getLastComputerMove = ->
    if moves.length > 1 then moves[moves.length - 1] else null

  makeMove = (move) ->
    if move not in moves
      GameState.set GameStates.THINKING
      processPlayerMove move

  processPlayerMove = (move) ->
    [moves, playerLine, playerMove] = AI.userTurn moves, move
    playerLine

  makeComputerMove = ->
    GameState.unset GameStates.THINKING
    processComputerMove()

  processComputerMove = ->
    [moves, computerLine, computerMove] = AI.computerTurn moves
    [computerMove, computerLine]

  processState = (playerLine, computerLine) ->
    playerWins = playerLine?
    computerWins = computerLine? and not playerLine?

    if playerLine? or computerLine?
      endGame playerWins
    else if moves.length is TOTAL_CELLS
      endGame()

    if playerWins
      playerLine
    else if computerWins
      computerLine

  endGame = (playerWins) ->
    GameState.unset state for state in [GameStates.DRAW, GameStates.PLAYER_WIN, GameStates.COMPUTER_WIN]
    endState = null
    if playerWins?
      endState = if playerWins then GameStates.PLAYER_WIN else GameStates.COMPUTER_WIN
    else
      endState = GameStates.DRAW
    GameState.set endState
    GameState.set GameStates.END_GAME

  gameReset = ->
    moves = []
    GameState.reset()

  { isValidMove, getLastComputerMove, makeMove, makeComputerMove, processState, gameReset }

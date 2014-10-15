require ['jquery', '3D', 'GameLogic', 'CellStates', 'GameState', 'GameStates'], ($, Board3D, GameLogic, CellStates, GameState, GameStates) ->
  $canvas = $ 'canvas'

  setCell = (cell, state) ->
    Board3D.setCellState cell, state

  getCell = (cell) ->
    Board3D.getCellState cell

  previousPossible = null
  showPossibleMoves = (e) ->
    if GameStates.READY_TO_RESET not in GameState.get()
      clearPossibleMove()

      possibleMove = Board3D.getMove e

      if not GameLogic.isValidMove(possibleMove) or getCell(possibleMove) is CellStates.TENTATIVE_MOVE
        possibleMove = null

      if possibleMove?
        clearTentativeMove()
        setCell possibleMove, CellStates.POSSIBLE_MOVE
        GameState.set GameStates.POSSIBLE_MOVE
      previousPossible = possibleMove

  clearPossibleMove = ->
    if previousPossible?
      setCell previousPossible, CellStates.DEFAULT
      previousPossible = null
      GameState.unset GameStates.POSSIBLE_MOVE

  selectCell = (e) ->
    if GameStates.READY_TO_RESET not in GameState.get()
      playerMove = Board3D.getMove e
      if GameLogic.isValidMove playerMove
        if getCell(playerMove) is CellStates.TENTATIVE_MOVE
          makeMove playerMove
        else
          tentativeMove playerMove

  makeMove = (playerMove) ->
    lastComputerMove = GameLogic.getLastComputerMove()
    if lastComputerMove
      setCell lastComputerMove, CellStates.COMPUTER_MOVE

    clearTentativeMove()
    playerLine = GameLogic.makeMove playerMove
    setCell playerMove, CellStates.PLAYER_MOVE
    GameState.unset GameStates.TENTATIVE_MOVE

    setTimeout (->
      computerLine = getComputerMove()
      checkPotentialWin GameLogic.processState playerLine, computerLine
    ), 500

  getComputerMove = ->
    [computerMove, computerLine] = GameLogic.makeComputerMove()
    setCell computerMove, CellStates.COMPUTER_LAST_MOVE
    computerLine

  previousTentative = null
  tentativeMove = (tentativeMove) ->
    clearTentativeMove()
    clearPossibleMove()

    setCell tentativeMove, CellStates.TENTATIVE_MOVE
    GameState.set GameStates.TENTATIVE_MOVE
    previousTentative = tentativeMove

  clearTentativeMove = ->
    if previousTentative
      setCell previousTentative, CellStates.DEFAULT
      previousTentative = null
      GameState.unset GameStates.TENTATIVE_MOVE

  checkPotentialWin = (line) ->
    showWin line if line?

  showWin = (line) ->
    for cell in line
      setCell cell, CellStates.WIN

  $ ->
    $canvas.on 'mousemove', showPossibleMoves
    $canvas.on 'click', selectCell
    GameState.set GameStates.HELP
    if Board3D.noWebGL
      GameState.set GamesStates.NO_WEBGL

    $('#Help').on 'click', ->
      GameState.unset GameStates.HELP

    $('#EndGame').on 'click', ->
      GameState.unset GameStates.END_GAME
      GameState.set GameStates.READY_TO_RESET

    $('#ResetView').on 'click', Board3D.resetView

    $('#ResetGame').on 'click', ->
      GameLogic.gameReset()
      Board3D.resetBoard()

    $('#IncreaseExplode').on 'click', Board3D.increaseExplode
    $('#DecreaseExplode').on 'click', Board3D.decreaseExplode
    $('#IncreaseZoom').on 'click', Board3D.increaseZoom
    $('#DecreaseZoom').on 'click', Board3D.decreaseZoom

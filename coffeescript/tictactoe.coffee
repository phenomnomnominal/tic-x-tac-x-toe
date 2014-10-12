require ['jquery', 'AI', 'cellStates', '2D', '3D', 'ResponsiveClass'], ($, AI, CellStates, Board2D, Board3D) ->
  TOTAL_CELLS = 4**3
  moves = null

  $navli = $ 'nav li'
  $help = $ '#Help'

  $td = $ 'td'
  $section = $ 'section'

  $thinking = $ '#Thinking'

  $endgame = $ '#EndGame'
  $draw = $ '#Draw'
  $player = $ '#Player'
  $computer = $ '#Computer'
  $noWebGL = $ '#NoWebGL'

  switchTab = ->
    $this = $(@)
    if not $this.hasClass 'active'
      $this.siblings().not(@).removeClass 'active'
      $this.addClass 'active'
      tabName = $this.data 'tab'
      $toShow = $ "##{tabName}"
      $section.not($toShow).hide()
      $toShow.show()
      $(window).trigger 'resize'

  hideHelp = ->
    $help.hide()

  updateBoards = (cell, state) ->
    Board2D.update cell, state
    Board3D.update cell, state

  resetBoards = ->
    updateBoards i for i in [0...TOTAL_CELLS]

  getMove = (td) ->
    +$(td).data 'move'

  gameReset = ->
    moves = []
    resetBoards()
    el.hide() for el in [$endgame, $thinking]

  showPossibleMove = ->
    move = getMove @
    if move not in moves
      updateBoards move, CellStates.POSSIBLE_MOVE

  hidePossibleMove = ->
    move = getMove @
    if move not in moves
      updateBoards move

  makeMove = ->
    move = getMove @
    if move not in moves
      $thinking.show()

      showPreviousComputerMove()
      playerLine = processPlayerMove move

      setTimeout (->
        $thinking.hide()
        computerLine = processComputerMove()
        processState playerLine, computerLine
      ), 500

  showPreviousComputerMove = ->
    if moves.length > 1
      updateBoards moves[moves.length - 1], CellStates.COMPUTER_MOVE

  processPlayerMove = (move) ->
    [moves, playerLine, playerMove] = AI.userTurn moves, move
    updateBoards playerMove, CellStates.PLAYER_MOVE
    playerLine

  processComputerMove = ->
    [moves, computerLine, computerMove] = AI.computerTurn moves
    updateBoards computerMove, CellStates.COMPUTER_LAST_MOVE
    computerLine

  processState = (playerLine, computerLine) ->
    playerWins = playerLine?
    computerWins = computerLine? and not playerLine?

    if playerWins
      showWin playerLine
    else if computerWins
      showWin computerLine

    if playerLine or computerLine
      endGame playerWins
    else if moves.length is TOTAL_CELLS
      endGame()

  showWin = (line) ->
    for cell in line
      updateBoards cell, CellStates.WIN

  endGame = (playerWins) ->
    el.hide() for el in [$draw, $player, $computer]
    if playerWins?
      (if playerWins then $player else $computer).show()
    else
      $draw.show()
    $endgame.show()

  $ ->
    $navli.on 'click', switchTab
    $td.on 'mouseover', showPossibleMove
    $td.on 'mouseout', hidePossibleMove
    $td.on 'click', makeMove
    $endgame.on 'click', gameReset
    $help.on 'click', hideHelp
    if Board3D.noWebGL then $noWebGL.show()
    gameReset()

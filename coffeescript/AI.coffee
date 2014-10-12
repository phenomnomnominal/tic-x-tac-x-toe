define ->
  N = 63
           # X DIRECTION
  lines = [[0,1,2,3], [4,5,6,7], [8,9,10,11], [12,13,14,15], #0, 1, 2, 3
           [16,17,18,19], [20,21,22,23], [24,25,26,27], [28,29,30,31], #4, 5, 6, 7
           [32,33,34,35], [36,37,38,39], [40,41,42,43], [44,45,46,47], #8, 9, 10, 11
           [48,49,50,51], [52,53,54,55], [56,57,58,59], [60,61,62,63], #12, 13, 14, 15
           #Y DIRECTION
           [0,4,8,12], [1,5,9,13], [2,6,10,14], [3,7,11,15], #16, 17, 18, 19
           [16,20,24,28], [17,21,25,29], [18,22,26,30], [19,23,27,31], #20, 21, 22, 23
           [32,36,40,44], [33,37,41,45], [34,38,42,46], [35,39,43,47], #24, 25, 26, 27
           [48,52,56,60], [49,53,57,61], [50,54,58,62], [51,55,59,63], #28, 29, 30, 31
           #Z DIRECTION
           [0,16,32,48], [1,17,33,49], [2,18,34,50], [3,19,35,51], # 32, 33, 34, 35
           [4,20,36,52], [5,21,37,53], [6,22,38,54], [7,23,39,55], #36, 37, 38, 39
           [8,24,40,56], [9,25,41,57], [10,26,42,58], [11,27,43,59], #40, 41, 42, 43
           [12,28,44,60], [13,29,45,61], [14,30,46,62], [15,31,47,63] #44, 45, 46, 47
           #XY DIRECTION
           [0,5,10,15], [16,21,26,31], [32,37,42,47], [48,53,58,63], #48, 49, 50, 51
           [3,6,9,12], [19,22,25,28], [35,38,41,44],  [51,54,57,60], #52, 53, 54, 55
           #XZ DIRECTION
           [0,20,40,60], [1,21,41,61], [2,22,42,62], [3,23,43,63], #56, 57, 58, 59
           [12,24,36,48], [13,25,37,49], [14,26,38,50], [15,27,39,51] #60, 61, 62, 63
           #YZ DIRECTION
           [0,17,34,51], [4,21,38,55], [8,25,42,59], [12,29,46,63], #64, 65, 66, 67
           [3,18,33,48], [7,22,37,52], [11,26,41,56], [15,30,45,60], #68, 69, 70, 71
           #XYZ DIRECTION
           [0,21,42,63], [3, 22,41,60], [12, 25, 38, 51], [15, 26, 37, 48]] #72, 73, 74, 75

  copy = (obj) ->
    temp = {__proto__: obj}
    return temp.__proto__

  Function::partial = ->
    func = @
    originalArgs = Array::slice.call(arguments)
    originalLength = originalArgs.length
    return ->
      args = []; i = 0; j = 0;
      if not arguments.length? then return func.apply(@, Array::slice.call(originalArgs))
      while i < originalLength
        args.push originalArgs[i]
        i += 1
      return func.apply(@, args.concat(Array::slice.call(arguments, j, arguments.length)))

  map = (func, array) ->
    if array.length is 0 then return []
    [func(array[0])].concat(map(func, array[1..]))

  class Tree
    constructor: (@node, @children) ->

  class GameState
    constructor: (@moves) ->

  getLineScores = (gameState, scores = []) ->
    winlossLevel = -1
    for line in lines
      score = 0
      moveCount = 0
      for move in gameState.moves
        if move in line
          if moveCount % 2 is 0
            score--
          else
            score++
        if Math.abs(score) is 4 and winlossLevel is -1
          winlossLevel = moveCount
        moveCount++
      scores.push(score)
    gameState.score = scores
    gameState.winlossLevel = if winlossLevel is -1 then moveCount + 1 else winlossLevel
    return gameState

  countScores = (gameState, scoreCounts = {}) ->
    for score in gameState.score
      scoreCounts[score] = if scoreCounts[score]? then scoreCounts[score] + 1 else 1
    gameState.score = scoreCounts
    return gameState

  getFinalScore = (gameState, score = 0) ->
    if gameState.score['4'] > 0 then score += gameState.score['4'] * 50000000
    if gameState.score['-4'] > 0 then score += gameState.score['-4'] * -5000000
    if gameState.score['3'] > 0 then score += gameState.score['3'] * 500000
    if gameState.score['-3'] > 0 then score += gameState.score['-3'] * -50000
    if gameState.score['2'] > 0 then score += gameState.score['2'] * 5000
    if gameState.score['-2'] > 0 then score += gameState.score['-2'] * -500
    if gameState.score['1'] > 0 then score += gameState.score['1'] * 50
    if gameState.score['-1'] > 0 then score += gameState.score['-1'] * -5
    gameState.score = score / gameState.winlossLevel
    return gameState

  class GameTree
    constructor: (usedSpaces, maxDepth) ->
      getFreeSpaces = (usedSpaces, freeSpaces) ->
        return (space for space in freeSpaces when space not in usedSpaces)

      getPly = (usedSpaces, freeSpaces) ->
        if freeSpaces.length > 0 then return [new GameState(usedSpaces.concat([freeSpaces[0]]))].concat(getPly(usedSpaces, freeSpaces[1..]))
        else []

      getNextBranch = (position, branch, tree) ->
        nextBranch = copy(branch)
        currentDepth = position.current
        parentDepth = currentDepth - 1
        if currentDepth < maxDepth
          nextBranch[currentDepth] = tree
          nextBranch = nextBranch[0..currentDepth]
        return nextBranch

      getNextTree = (position, branch, tree, freeSpaces) ->
        currentDepth = position.current
        parentDepth = currentDepth - 1
        currentVariation = position[currentDepth]
        nextNode = branch[parentDepth].children[currentVariation]
        if currentDepth < maxDepth then return new Tree(nextNode, getPly(nextNode.moves, getFreeSpaces(nextNode.moves, freeSpaces)))
        else return new Tree(getFinalScore(countScores(getLineScores(nextNode))), [])

      getNextPosition = (position) ->
        nextPosition = copy(position)
        currentDepth = position.current
        if position[currentDepth] < (freeSpaces.length - currentDepth) and currentDepth is maxDepth
          nextPosition[currentDepth] = position[currentDepth] + 1
          return nextPosition
        endOfRow = -> return (position[currentDepth] is (freeSpaces.length - currentDepth) and (currentDepth is maxDepth or position[currentDepth + 1] is (freeSpaces.length - currentDepth - 1)))
        if endOfRow()
          currentDepth -= 1
          while endOfRow()
            currentDepth -= 1
          if currentDepth <= 0
            return false
          nextPosition[currentDepth] += 1
          nextPosition[i] = undefined for i in [currentDepth + 1..maxDepth] when nextPosition[i]?
          nextPosition.current = currentDepth
          return nextPosition
        if currentDepth < maxDepth
          currentDepth += 1
          nextPosition[currentDepth] = 0
          nextPosition.current = currentDepth
          return nextPosition
        return false
      freeSpaces = (p for p in [0..63] when p not in usedSpaces)
      maxDepth = Math.min(maxDepth, N - (usedSpaces.length))

      getTree = ->
        self = arguments.callee
        currentPosition = self.nextPosition
        currentBranch = self.nextBranch
        currentTree = self.nextTree
        self.nextPosition = getNextPosition(currentPosition)
        if self.nextPosition isnt false
          self.nextTree = getNextTree(self.nextPosition, currentBranch, currentTree, freeSpaces)
          self.nextBranch = getNextBranch(self.nextPosition, currentBranch, self.nextTree)
        return currentTree

      getTree.nextTree = new Tree(new GameState(usedSpaces), getPly(usedSpaces, freeSpaces))
      getTree.nextBranch = [getTree.nextTree]
      getTree.nextPosition = current: 0, '0': 0
      return getTree

  max = (gameStates) ->
    if gameStates.length is 0 then return null
    if gameStates.length is 1 then return gameStates[0]
    maxScoring = gameStates[0]
    maxScoring = state for state in gameStates[1..] when state.score > maxScoring.score
    maxScoring

  min = (gameStates) ->
    if gameStates.length is 0 then return null
    if gameStates.length is 1 then return gameStates[0]
    minScoring = gameStates[0]
    minScoring = state for state in gameStates[1..] when state.score < minScoring.score
    minScoring

  maximise = (gameTree) ->
    ct = gameTree()
    if ct.children.length is 0 then return [ct.node]
    mapmin(map(minimise.partial(gameTree), ct.children))

  minimise = (gameTree) ->
    ct = gameTree()
    if ct.children.length is 0 then return [ct.node]
    mapmax(map(maximise.partial(gameTree), ct.children))

  mapmin = (minimised) ->
    potential = min(minimised[0])
    return [potential].concat(omitSmaller(potential, minimised[1..]))

  mapmax = (maximised) ->
    potential = max(maximised[0])
    return [potential].concat(omitLarger(potential, maximised[1..]))

  omitLarger = (potential, values) ->
    if values.length is 0 then return []
    if maxgt(potential, values[0]) then return omitLarger(potential, values[1..])
    newMinMax = max(values[0])
    return [newMinMax].concat(omitLarger(newMinMax, values[1..]))

  omitSmaller = (potential, values) ->
    if values.length is 0 then return []
    if minleq(potential, values[0]) then return omitSmaller(potential, values[1..])
    newMaxMin = min(values[0])
    return [newMaxMin].concat(omitSmaller(newMaxMin, values[1..]))

  maxgt = (potential, values) ->
    if values.length is 0 then return false
    if values[0].score > potential.score then return true
    return maxgt(potential, values[1..])

  minleq = (potential, values) ->
    if values.length is 0 then return false
    if values[0].score <= potential.score then return true
    return minleq(potential, values[1..])


  containsLine = (moves, line) ->
    if line.length is 0
      return true
    if line[0] in moves
      return containsLine(moves, line[1..])
    else return false

  checkWin = (moves) ->
    for line in lines
      if containsLine(moves, line) then return line
    return false

  checkWinLoseDraw = (moves) ->
    p1 = []
    p2 = []
    moveCount = 0
    for move in moves
      if moveCount % 2 is 0 then p1.push(move)
      else p2.push(move)
      moveCount++
    p1line = checkWin(p1)
    if p1line isnt false then return [1, p1line]
    p2line = checkWin(p2)
    if p2line isnt false then return [-1, p2line]
    if moves.length is 64 then return [0, null]
    else return [2, null]

  checkEnd = (moves) ->
    if moves.length >= 7
      [winLoseDraw, line] = checkWinLoseDraw(moves)
      if winLoseDraw is 1 then return [moves, line]
      if winLoseDraw is -1 then return [moves, line]
      if winLoseDraw is 0 then return [moves, null]
    return [moves, null]

  userTurn = (moves, usermove) ->
    if not (usermove in moves)
      moves.push(usermove)
      [moves, line] = checkEnd(moves)
      if line isnt null then return [moves, line, usermove]
    else
      throw new Error 'Position already taken'
    return [moves, null, usermove]

  depth = 2
  computerTurn = (moves) ->
    if moves.length is 23 then depth is 3
    if moves.length is 43 then depth is 4
    if moves.length is 53 then depth is 7
    if moves.length is 63 then depth is 1
    moves.push(max(maximise(new GameTree(moves, depth))).moves[moves.length])
    computermove = moves[moves.length - 1]
    [moves, line] = checkEnd(moves)
    if line isnt null then return [moves, line, computermove]
    return [moves, null, computermove]

  { userTurn, computerTurn }

define ['jquery', 'three', 'CellStates', 'orbit'], ($, Three, CellStates) ->
  $window = $ window
  $canvas = $ 'canvas'

  SCENE = null
  CAMERA = null
  CONTROLS = null
  CAMERA_FOV = 45
  BOARD = null
  GEOMETRY = null
  MATERIALS = {}
  RENDERER = null
  PROJECTOR = null

  noWebGL = not window.WebGLRenderingContext

  explode = 1
  animationQueue = []

  addCubes = ->
    for n in [4**3 - 1..0]
      cube = new THREE.Mesh(GEOMETRY, MATERIALS.default)
      BOARD.add cube

  setExplode = (newExplode) ->
    if newExplode > 5
      newExplode = 5
    if newExplode < 1
      newExplode = 1
    explode = newExplode
    for n in [4**3 - 1..0]
      cube = BOARD.children[n]
      cube.position.setX (-1.5 + Math.floor(n / 16)) * explode
      cube.position.setY (-1.5 + Math.floor((n % 16) / 4)) * explode
      cube.position.setZ (-1.5 + (n % 4)) * explode

  zoomIn = ->
    CONTROLS.dollyOut()
    CONTROLS.update()

  zoomOut = ->
    CONTROLS.dollyIn()
    CONTROLS.update()

  setCellState = (cell, state) ->
    BOARD.children[cell].material = MATERIALS[state]

  getCellState = (cell) ->
    state = Object.keys(CellStates)
      .map (CellState) ->
        CellStates[CellState]
      .filter (CellState) ->
        BOARD.children[cell].material is MATERIALS[CellState]
    state[0]

  initialiseBoard = ->
    SCENE = new Three.Scene()

    BOARD = new Three.Object3D()
    SCENE.add BOARD

    light1 = new Three.PointLight(0xFFEEAA, 0.5)
    light1.position = new Three.Vector3(-40, 40, -40)
    SCENE.add light1

    light2 = new Three.PointLight(0xFFEEAA, 0.5)
    light2.position = new Three.Vector3(40, 40, 40)
    SCENE.add light2

    GEOMETRY = new Three.BoxGeometry(1, 1, 1)
    MATERIALS[CellStates.DEFAULT] = new Three.MeshBasicMaterial(color: 0xAAAAAA, opacity : 0.25, depthTest : no, transparent: yes)
    MATERIALS[CellStates.POSSIBLE_MOVE] = new Three.MeshBasicMaterial(color: 0xFF0000, opacity : 0.25, depthTest : no, transparent: yes)
    MATERIALS[CellStates.TENTATIVE_MOVE] = new Three.MeshBasicMaterial(color: 0xFF0000, opacity : 0.50, depthTest : no, transparent: yes)
    MATERIALS[CellStates.PLAYER_MOVE] = new Three.MeshBasicMaterial(color: 0xFF0000, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.COMPUTER_MOVE] = new Three.MeshBasicMaterial(color: 0x0000FF, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.COMPUTER_LAST_MOVE] = new Three.MeshBasicMaterial(color: 0xAAAAFF, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.WIN] = new Three.MeshBasicMaterial(color: 0x00FF00, opacity : 0.75, depthTest : no, transparent: yes)

    if noWebGL
      RENDERER = new Three.CanvasRenderer(canvas: $canvas.get(0), antialias: yes, alpha: yes)
    else
      RENDERER = new Three.WebGLRenderer(canvas: $canvas.get(0), antialias: yes, alpha: yes)

    RENDERER.setSize $window.width(), $window.height()
    RENDERER.setClearColor 0xFFFFFF, 1

    CAMERA = new Three.PerspectiveCamera(CAMERA_FOV, $window.width() / $window.height(), 0.1, 400)
    CAMERA.position.z = 12
    SCENE.add CAMERA

    CONTROLS = new Three.OrbitControls(CAMERA, $canvas.get(0))
    CONTROLS.noPan = true
    CONTROLS.noZoom = true
    
    PROJECTOR = new THREE.Projector()

    addCubes()
    setExplode 1

  rafLoop = ->
    requestAnimationFrame rafLoop
    if animationQueue.length
      animationQueue.shift()()
    RENDERER.render SCENE, CAMERA

  resize = ->
    CAMERA.aspect = $window.width() / $window.height()
    CAMERA.updateProjectionMatrix()
    RENDERER.setSize $window.width(), $window.height()

  intersect = (e) ->
    $target = $ e.target
    x = (e.offsetX / $target.width()) * 2 - 1
    y = -(e.offsetY / $target.height()) * 2 + 1
    mouse3D = new THREE.Vector3(x, y, 0.5)
    raycaster = PROJECTOR.pickingRay mouse3D.clone(), CAMERA
    intersections = raycaster.intersectObjects BOARD.children

  getMove = (e) ->
    intersections = intersect e
    intersection = intersections[0]
    if intersection
      BOARD.children.indexOf intersection.object

  resetView = ->
    CONTROLS.reset()
    animationQueue = []
    setExplode 1

  resetBoard = ->
    setCellState cell, CellStates.DEFAULT for cell in [0...4**3]
    resetView()

  createAnimation = (func, start, end, steps = 15) ->
    if animationQueue.length > 0
      animationQueue[animationQueue.length - 1]()
    animationQueue = []

    for n in [0...steps]
      step = n / (steps - 1)
      if start? and end?
        animationQueue.push func.bind null, (1 - step) * start + step * end
      else
        animationQueue.push func.bind null

  increaseExplode = ->
    createAnimation setExplode, explode, explode + 1

  decreaseExplode = ->
    createAnimation setExplode, explode, explode - 1

  increaseZoom = ->
    createAnimation zoomIn

  decreaseZoom = ->
    createAnimation zoomOut

  $ ->
    $window.on 'resize', resize
    initialiseBoard()
    resize()
    rafLoop()

  { noWebGL, setCellState, getCellState, getMove, resetView, resetBoard, increaseExplode, decreaseExplode, increaseZoom, decreaseZoom }
